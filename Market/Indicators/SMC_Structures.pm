package Market::Indicators::SMC_Structures;

# =============================================================================
# Market::Indicators::SMC_Structures
# =============================================================================
# DEPRECATED — alias de compatibilidad con la especificacion (Tabla 1).
# Use L<Market::Structure::StructureEngine> en codigo nuevo.
# =============================================================================
# Package de la especificacion (Tabla 1). Delega al motor unificado de
# estructura de mercado: BOS, CHoCH, swings y tendencia.
# =============================================================================

use strict;
use warnings;

use parent 'Market::Structure::StructureEngine';

1;
