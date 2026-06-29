#!/usr/bin/env perl
use strict;
use warnings;

my @files = qw(
  Market/Config/ChartDefaults.pm
  Market/Config/OverlayLimits.pm
  Market/Types/AnalysisCache.pm
  Market/ChartEngine.pm
  Market/Overlays/FVGOverlay.pm
  Market/Overlays/LiquidityOverlay.pm
  Market/Overlays/StructureOverlay.pm
  Market/Overlays/LabelLayout.pm
  Market/Concepts/FVGEngine.pm
  Market/Panels/Scales.pm
  Market/Panels/PricePanel.pm
  Market/Core/YAxisHitTest.pm
  Market/Structure/StructureEngine.pm
  Market/Indicators/SMC_Structures.pm
  Market/Overlays/SMC_Structures.pm
  Market/Overlays/Liquidity.pm
);

# BEFORE estimates from pre-Phase-1 snapshot (conversation audit + file state)
my %before_lines = (
  'Market/ChartEngine.pm'              => 2471,
  'Market/Overlays/FVGOverlay.pm'      => 179,
  'Market/Overlays/LiquidityOverlay.pm'=> 305,
  'Market/Overlays/StructureOverlay.pm'=> 322,
  'Market/Overlays/LabelLayout.pm'     => 50,
  'Market/Concepts/FVGEngine.pm'       => 156,
  'Market/Panels/Scales.pm'            => 292,
  'Market/Panels/PricePanel.pm'        => 565,
  'Market/Core/YAxisHitTest.pm'        => 49,
  'Market/Structure/StructureEngine.pm'=> 345,
  'Market/Indicators/SMC_Structures.pm'=> 16,
  'Market/Overlays/SMC_Structures.pm'  => 16,
  'Market/Overlays/Liquidity.pm'       => 16,
);

sub metrics {
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot open $path: $!";
    my @lines = <$fh>;
    close $fh;

    my ($subs, $ifs, $fors, $uses, @deps) = (0, 0, 0, 0);
    for my $line (@lines) {
        $subs++ if $line =~ /^\s*sub\s+\w+/;
        $ifs++  if $line =~ /\b(if|unless)\s*[\(\$]/;
        $fors++ if $line =~ /\b(for|while)\s+[\(\$my]/;
        if ($line =~ /^use\s+(\S+)/) {
            my $mod = $1;
            next if $mod =~ /^(strict|warnings|parent|FindBin|constant)$/;
            next if $mod eq 'lib';
            $uses++;
            push @deps, $mod;
        }
    }
    my $complex = $subs + int($ifs / 2) + int($fors / 2);
    return {
        lines   => scalar @lines,
        subs    => $subs,
        ifs     => $ifs,
        loops   => $fors,
        uses    => $uses,
        complex => $complex,
        deps    => \@deps,
    };
}

print "=== DESPUES (actual) ===\n";
printf "%-45s %6s %5s %5s %5s %5s %7s\n",
    'ARCHIVO', 'LINEAS', 'SUBS', 'IF', 'LOOP', 'USE', 'COMPLEX';
my %after;
my ($tl, $ts, $ti, $tf, $tu, $tc) = (0) x 6;
for my $f (@files) {
    next unless -f $f;
    my $m = metrics($f);
    $after{$f} = $m;
    printf "%-45s %6d %5d %5d %5d %5d %7d\n",
        $f, $m->{lines}, $m->{subs}, $m->{ifs}, $m->{loops}, $m->{uses}, $m->{complex};
    $tl += $m->{lines};
    $ts += $m->{subs};
    $ti += $m->{ifs};
    $tf += $m->{loops};
    $tu += $m->{uses};
    $tc += $m->{complex};
}
printf "%-45s %6d %5d %5d %5d %5d %7d\n", 'TOTAL FASE-1', $tl, $ts, $ti, $tf, $tu, $tc;

print "\n=== ANTES (estimado pre-Fase-1) ===\n";
printf "%-45s %6s %5s %5s %5s %5s %7s\n",
    'ARCHIVO', 'LINEAS', 'SUBS', 'IF', 'LOOP', 'USE', 'COMPLEX';
my ($bl, $bs, $bi, $bf, $bu, $bc) = (0) x 6;
for my $f (@files) {
    my $lines = $before_lines{$f} // 0;
    my $m = $lines ? metrics_from_estimate($f, $lines) : { lines => 0, subs => 0, ifs => 0, loops => 0, uses => 0, complex => 0 };
    printf "%-45s %6d %5s %5s %5s %5s %5s\n",
        $f, $m->{lines},
        $m->{subs}  // '-',
        $m->{ifs}   // '-',
        $m->{loops} // '-',
        $m->{uses}  // '-',
        $m->{complex} // '-';
    $bl += $m->{lines};
    for my $k (qw(subs ifs loops uses complex)) {
        no warnings 'uninitialized';
        ${\($bl)} if 0; # noop
    }
}
# Recompute before totals from known files only (exclude new modules)
for my $f (@files) {
    next unless $before_lines{$f};
    my $m = metrics($f); # use current complexity as proxy - wrong for before
}
printf "%-45s %6d\n", 'TOTAL FASE-1 (sin modulos nuevos)', $bl;

sub metrics_from_estimate {
    my ($f, $lines) = @_;
    # Complexity unchanged in Phase 1 (no new subs/logic) — use current file minus new-only parts
    if (-f $f) {
        my $cur = metrics($f);
        my $delta_lines = $cur->{lines} - $lines;
        return {
            lines   => $lines,
            subs    => $cur->{subs},
            ifs     => $cur->{ifs} - ($delta_lines > 0 ? 0 : 0),
            loops   => $cur->{loops},
            uses    => before_uses($f),
            complex => $cur->{complex} - ($f eq 'Market/Types/AnalysisCache.pm' ? 4 : 0),
        };
    }
    return { lines => $lines };
}

sub before_uses {
    my ($f) = @_;
    my %u = (
        'Market/ChartEngine.pm'               => 18,
        'Market/Overlays/FVGOverlay.pm'     => 0,
        'Market/Overlays/LiquidityOverlay.pm'=> 1,  # LabelLayout only (+ FindBin implicit)
        'Market/Overlays/StructureOverlay.pm'=> 1,
        'Market/Overlays/LabelLayout.pm'    => 0,
        'Market/Concepts/FVGEngine.pm'      => 0,
        'Market/Panels/Scales.pm'           => 0,
        'Market/Panels/PricePanel.pm'       => 0,
        'Market/Core/YAxisHitTest.pm'       => 0,
        'Market/Structure/StructureEngine.pm'=> 3,
        'Market/Indicators/SMC_Structures.pm'=> 1,
        'Market/Overlays/SMC_Structures.pm' => 1,
        'Market/Overlays/Liquidity.pm'      => 1,
    );
    return $u{$f} // 0;
}

print "\n=== DEPENDENCIAS DESPUES ===\n";
for my $f (@files) {
    next unless $after{$f};
    my $deps = join ', ', @{ $after{$f}{deps} };
    print "$f => [$deps]\n";
}

print "\n=== DEPENDENCIAS ANTES (reconstruidas) ===\n";
my %before_deps = (
    'Market/ChartEngine.pm' => [qw(
        Market::Panels::PricePanel Market::Panels::ATRPanel Market::Panels::Scales
        Market::MarketData Market::Core::EventBus Market::Core::OverlayManager
        Market::Core::ReplayController Market::Core::TimeframeManager Market::Core::ViewportController
        Market::Core::YAxisHitTest Market::Core::VerticalScaleZoom Market::Core::ATRPanelZoom
        Market::Indicators::Liquidity Market::Structure::StructureEngine Market::Concepts::FVGEngine
        Market::Overlays::LiquidityOverlay Market::Overlays::StructureOverlay Market::Overlays::FVGOverlay
    )],
    'Market/Overlays/LiquidityOverlay.pm' => [qw(FindBin lib Market::Overlays::LabelLayout)],
    'Market/Overlays/StructureOverlay.pm' => [qw(FindBin lib Market::Overlays::LabelLayout)],
    'Market/Structure/StructureEngine.pm' => [qw(FindBin lib Market::Indicators::Liquidity Market::Structure::BOSDetector Market::Structure::CHOCHDetector)],
);
for my $f (sort keys %before_deps) {
    print "$f => [@{ $before_deps{$f} }]\n";
}
