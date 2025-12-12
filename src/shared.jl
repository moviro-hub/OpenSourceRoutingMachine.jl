"""
    OutputFormat

Selects the output format for OSRM responses (`json`, `flatbuffers`).
"""
@cenum(OutputFormat::Int32, begin
    json = 0
    flatbuffers = 1
end)

"""
    Algorithm

Selects the routing algorithm OSRM should use for a given dataset (`ch`, `mld`).
"""
@cenum(Algorithm::Int32, begin
    ch = 0
    mld = 1
end)

"""
    Snapping

Selects the snapping behavior OSRM should use for a given dataset (`default`, `any`).
"""
@cenum(Snapping::Int32, begin
    default = 0
    any = 1
end)

"""
    Approach

Selects the approach behavior OSRM should use for a given dataset (`curb`, `unrestricted`, `opposite`).
"""
@cenum(Approach::Int32, begin
    curb = 0
    unrestricted = 1
    opposite = 2
end)

"""
    Geometries

Selects the geometry encoding format for route geometries (`polyline`, `polyline6`, `geojson`).
"""
@cenum(Geometries::Int32, begin
    polyline = 0
    polyline6 = 1
    geojson = 2
end)

"""
    Overview

Controls how much geometry detail OSRM should include (`simplified`, `full`, `false_`).
"""
@cenum(Overview::Int32, begin
    simplified = 0
    full = 1
    false_ = 2
end)

"""
    Annotations

Bit flags for requesting additional metadata in route responses. Values can be combined using bitwise OR (`|`).

The enum values correspond to bit positions:
- `none = 0`: No annotations
- `duration = 1` (bit 0): Request duration annotations
- `nodes = 2` (bit 1): Request node annotations
- `distance = 4` (bit 2): Request distance annotations
- `weight = 8` (bit 3): Request weight annotations
- `datasources = 16` (bit 4): Request datasource annotations
- `speed = 32` (bit 5): Request speed annotations
- `all = 63`: All annotations (bitwise OR of all flags)
"""
@cenum(Annotations::Int32, begin
    none = 0
    duration = 1
    nodes = 2
    distance = 4
    weight = 8
    datasources = 16
    speed = 32
    all = 63 # duration | nodes | distance | weight | datasources | speed
end)

# Parameter helper declarations live here so service modules can extend these functions
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

# Response helper declarations live here so service modules can extend these functions
function get_format end
function get_json end
function get_flatbuffer end
