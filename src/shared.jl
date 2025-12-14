"""
    Algorithm

Selects the routing algorithm OSRM should use for a given dataset (`algorithm_ch`, `algorithm_mld`).
"""
@cenum(
    Algorithm::Int32, begin
        algorithm_ch = 0
        algorithm_mld = 1
    end
)

"""
    Snapping

Selects the snapping behavior OSRM should use for a given dataset (`snapping_default`, `snapping_any`).
"""
@cenum(
    Snapping::Int32, begin
        snapping_default = 0
        snapping_any = 1
    end
)

"""
    Approach

Selects the approach behavior OSRM should use for a given dataset (`approach_curb`, `approach_unrestricted`, `approach_opposite`).
"""
@cenum(
    Approach::Int32, begin
        approach_curb = 0
        approach_unrestricted = 1
        approach_opposite = 2
    end
)

"""
    Geometries

Selects the geometry encoding format for route geometries (`geometries_polyline`, `geometries_polyline6`, `geometries_geojson`).
"""
@cenum(
    Geometries::Int32, begin
        geometries_polyline = 0
        geometries_polyline6 = 1
        geometries_geojson = 2
    end
)

"""
    Overview

Controls how much geometry detail OSRM should include (`overview_simplified`, `overview_full`, `overview_false`).
"""
@cenum(
    Overview::Int32, begin
        overview_simplified = 0
        overview_full = 1
        overview_false = 2
    end
)

"""
    Annotations

Bit flags for requesting additional metadata in route responses. Values can be combined using bitwise OR (`|`).

The enum values correspond to bit positions:
- `annotations_none = 0`: No annotations
- `annotations_duration = 1` (bit 0): Request duration annotations
- `annotations_nodes = 2` (bit 1): Request node annotations
- `annotations_distance = 4` (bit 2): Request distance annotations
- `annotations_weight = 8` (bit 3): Request weight annotations
- `annotations_datasources = 16` (bit 4): Request datasource annotations
- `annotations_speed = 32` (bit 5): Request speed annotations
- `annotations_all = 63`: All annotations (bitwise OR of all flags)
"""
@cenum(
    Annotations::Int32, begin
        annotations_none = 0
        annotations_duration = 1
        annotations_nodes = 2
        annotations_distance = 4
        annotations_weight = 8
        annotations_datasources = 16
        annotations_speed = 32
        annotations_all = 63 # annotations_duration | annotations_nodes | annotations_distance | annotations_weight | annotations_datasources | annotations_speed
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
