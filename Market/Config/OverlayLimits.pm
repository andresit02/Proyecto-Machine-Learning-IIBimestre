package Market::Config::OverlayLimits;

use strict;
use warnings;

# Limites de densidad y fade para overlays (Fase 1 — sin logica de calculo).

use constant LIQUIDITY_MAX_EVENTS_PER_VIEWPORT => 40;

use constant FVG_MAX_AGE_BARS                => 50;
use constant FVG_HISTORY_BUFFER_MULTIPLIER   => 4;
use constant FVG_MAX_RENDER_PER_VIEWPORT     => 60;
use constant FVG_MIN_STRENGTH                => 0.08;
use constant FVG_MIN_LABEL_STRENGTH          => 0.15;

use constant FVG_STIPPLE_STRONG              => 0.66;
use constant FVG_STIPPLE_MEDIUM              => 0.40;

use constant LABEL_COLLISION_Y_THRESHOLD     => 10;
use constant LABEL_COLLISION_X_STEP          => 12;
use constant STRUCTURE_LABEL_COLLISION_Y     => 12;
use constant STRUCTURE_LABEL_COLLISION_X     => 14;

1;
