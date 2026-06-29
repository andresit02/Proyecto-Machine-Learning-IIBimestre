package Market::Config::ChartDefaults;

use strict;
use warnings;

# Constantes de layout y viewport por defecto del chart (Fase 1 — sin logica).
# Valores identicos a los literales previos en ChartEngine / Panels.

use constant INITIAL_VISIBLE_BARS        => 250;
use constant MAX_VISIBLE_BARS              => 1_000_000;
use constant DEFAULT_ATR_HEIGHT            => 110;
use constant TIME_AXIS_HEIGHT              => 42;
use constant Y_AXIS_STRIP_W                => 66;
use constant MIN_VISIBLE_BARS              => 10;
use constant MIN_EDGE_BARS                 => 2;
use constant ANALYSIS_VIEW_BUFFER_RATIO    => 0.75;

1;
