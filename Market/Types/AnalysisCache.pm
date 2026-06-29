package Market::Types::AnalysisCache;

use strict;
use warnings;

=pod

=head1 NAME

Market::Types::AnalysisCache - Contrato del hash C<analysis_cache>

=head1 SYNOPSIS

    use Market::Types::AnalysisCache;

    my $cache = Market::Types::AnalysisCache->build(
        liquidity => $liquidity_data,
        structure => $structure_data,
        fvg       => $fvg_data,
    );

    my $map = Market::Types::AnalysisCache->overlay_map($cache);

=head1 SCHEMA

El hash C<analysis_cache> en ChartEngine contiene exactamente tres entradas:

=over 4

=item C<liquidity> — resultado de L<Market::Indicators::Liquidity/calculate>

Campos esperados: C<swings>, C<eq_levels>, C<liquidity_levels>, C<events>, C<metadata>.

=item C<structure> — resultado de L<Market::Structure::StructureEngine/calculate>

Campos esperados: C<swings>, C<trend>, C<breaks>, C<changes>, C<metadata>.

=item C<fvg> — resultado de L<Market::Concepts::FVGEngine/calculate>

Campos esperados: C<gaps>, C<active>, C<metadata>.

=back

Cada valor es un hashref (nunca undef tras C<build>).

=head1 METHODS

=cut

sub cache_keys {
    return qw(liquidity structure fvg);
}

sub build {
    my ($class, %parts) = @_;
    my %cache;
    for my $key ($class->cache_keys()) {
        $cache{$key} = $parts{$key};
    }
    return \%cache;
}

sub overlay_map {
    my ($class, $cache) = @_;
    return {} unless $cache && ref $cache eq 'HASH';
    my %map;
    for my $key ($class->cache_keys()) {
        $map{$key} = $cache->{$key};
    }
    return \%map;
}

sub validate {
    my ($class, $cache) = @_;
    return 0 unless $cache && ref $cache eq 'HASH';
    for my $key ($class->cache_keys()) {
        return 0 unless exists $cache->{$key};
        return 0 unless ref $cache->{$key} eq 'HASH';
    }
    return 1;
}

1;
