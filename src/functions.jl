"""
    distance(response, ...) -> Float32

Compute distance from OSRM response objects. Methods are defined for:
- `RouteResponse`: returns total route distance
- `NearestResponse`: returns distance to nearest point at given index
- `TripResponse`: returns total trip distance
"""
function distance end

"""
    duration(response, ...) -> Float32

Compute duration from OSRM response objects. Methods are defined for:
- `RouteResponse`: returns total route duration
- `TripResponse`: returns total trip duration
"""
function duration end

function as_json end

# Parameter helper declarations live here so service modules can extend these
# functions without depending on a dedicated Params module.
function add_steps! end
function add_alternatives! end
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
function add_roundtrip! end
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
function set_format! end
