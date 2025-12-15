# Shared declarations for all modules
"""
    Algorithm

Selects the routing algorithm OSRM should use for a given dataset (`ALGORITHM_CH`, `ALGORITHM_MLD`).
"""
@cenum(
    Algorithm::Int32, begin
        ALGORITHM_CH = 0
        ALGORITHM_MLD = 1
    end
)

"""
    Snapping

Selects the snapping behavior OSRM should use for a given dataset (`SNAPPING_DEFAULT`, `SNAPPING_ANY`).
"""
@cenum(
    Snapping::Int32, begin
        SNAPPING_DEFAULT = 0
        SNAPPING_ANY = 1
    end
)

"""
    Approach

Selects the approach behavior OSRM should use for a given dataset (`APPROACH_CURB`, `APPROACH_UNRESTRICTED`, `APPROACH_OPPOSITE`).
"""
@cenum(
    Approach::Int32, begin
        APPROACH_CURB = 0
        APPROACH_UNRESTRICTED = 1
        APPROACH_OPPOSITE = 2
    end
)

"""
    Geometries

Selects the geometry encoding format for route geometries (`GEOMETRIES_POLYLINE`, `GEOMETRIES_POLYLINE6`, `GEOMETRIES_GEOJSON`).
"""
@cenum(
    Geometries::Int32, begin
        GEOMETRIES_POLYLINE = 0
        GEOMETRIES_POLYLINE6 = 1
        GEOMETRIES_GEOJSON = 2
    end
)

"""
    Overview

Controls how much geometry detail OSRM should include (`OVERVIEW_SIMPLIFIED`, `OVERVIEW_FULL`, `OVERVIEW_FALSE`).
"""
@cenum(
    Overview::Int32, begin
        OVERVIEW_SIMPLIFIED = 0
        OVERVIEW_FULL = 1
        OVERVIEW_FALSE = 2
    end
)

"""
    Annotations

Bit flags for requesting additional metadata in route responses. Values can be combined using bitwise OR (`|`).

The enum values correspond to bit positions:
- `ANNOTATIONS_NONE = 0`: No annotations
- `ANNOTATIONS_DURATION = 1` (bit 0): Request duration annotations
- `ANNOTATIONS_NODES = 2` (bit 1): Request node annotations
- `ANNOTATIONS_DISTANCE = 4` (bit 2): Request distance annotations
- `ANNOTATIONS_WEIGHT = 8` (bit 3): Request weight annotations
- `ANNOTATIONS_DATASOURCES = 16` (bit 4): Request datasource annotations
- `ANNOTATIONS_SPEED = 32` (bit 5): Request speed annotations
- `ANNOTATIONS_ALL = 63`: All annotations (bitwise OR of all flags)
"""
@cenum(
    Annotations::Int32, begin
        ANNOTATIONS_NONE = 0
        ANNOTATIONS_DURATION = 1
        ANNOTATIONS_NODES = 2
        ANNOTATIONS_DISTANCE = 4
        ANNOTATIONS_WEIGHT = 8
        ANNOTATIONS_DATASOURCES = 16
        ANNOTATIONS_SPEED = 32
        ANNOTATIONS_ALL = 63 # ANNOTATIONS_DURATION | ANNOTATIONS_NODES | ANNOTATIONS_DISTANCE | ANNOTATIONS_WEIGHT | ANNOTATIONS_DATASOURCES | ANNOTATIONS_SPEED
    end
)

"""
    Verbosity

Log verbosity level for OSRM tools (`VERBOSITY_NONE`, `VERBOSITY_ERROR`, `VERBOSITY_WARNING`, `VERBOSITY_INFO`, `VERBOSITY_DEBUG`).
"""
@cenum(
    Verbosity::Int32, begin
        VERBOSITY_NONE = 0
        VERBOSITY_ERROR = 1
        VERBOSITY_WARNING = 2
        VERBOSITY_INFO = 3
        VERBOSITY_DEBUG = 4
    end
)

# Parameter helper declarations
function set_steps! end
function set_alternatives! end
function set_geometries! end
function set_overview! end
function set_continue_straight! end
function set_number_of_alternatives! end
function set_annotations! end
function add_waypoint! end
function clear_waypoints! end
function set_annotations_mask! end
function set_fallback_speed! end
function set_fallback_coordinate_type! end
function set_scale_factor! end
function add_source! end
function add_destination! end
function set_number_of_results! end
function add_timestamp! end
function set_gaps! end
function set_tidy! end
function set_roundtrip! end
function set_source! end
function set_destination! end
function set_x! end
function set_y! end
function set_z! end
function add_coordinate! end
function add_coordinate_with! end
function set_hint! end
function set_radius! end
function set_bearing! end
function set_approach! end
function add_exclude! end
function set_generate_hints! end
function set_skip_waypoints! end
function set_snapping! end

# Response helper declarations
function get_flatbuffer end
