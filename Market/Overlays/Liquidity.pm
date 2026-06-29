package Market::Overlays::Liquidity;

# =============================================================================
# Market::Overlays::Liquidity
# =============================================================================
# DEPRECATED — alias de compatibilidad con la especificacion (Tabla 1 / §4.5).
# Use L<Market::Overlays::LiquidityOverlay> en codigo nuevo.
# =============================================================================
# Package de la especificacion (Tabla 1 / §4.5). Renderizado de liquidez:
# BSL, SSL, EQH/EQL, Sweep/Grab/Run con etiquetas y colores del spec.
# =============================================================================

use strict;
use warnings;

use parent 'Market::Overlays::LiquidityOverlay';

1;
