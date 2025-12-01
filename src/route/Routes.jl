module Routes

using ..Utils: Utils, with_error, error_pointer, check_error, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM,
    get_distance,
    get_duration,
    as_json,
    get_waypoint_count,
    get_waypoint_coordinate,
    libosrmc,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!,
    add_coordinate!,
    add_coordinate_with!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!,
    LatLon,
    Approach,
    Snapping

include("response.jl")
include("params.jl")

"""
    route(osrm::OSRM, params::RouteParams) -> RouteResponse

Calls the libosrmc Route endpoint directly, avoiding HTTP and keeping responses
in-memory.
"""
function route(osrm::OSRM, params::RouteParams)
    ptr = with_error() do err
        ccall((:osrmc_route, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return RouteResponse(ptr)
end

## Parameter exports
export
    RouteParams,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!,
    add_coordinate!,
    add_coordinate_with!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!

## Response exports
export
    RouteResponse,
    route,
    as_json,
    get_distance,
    get_duration,
    get_alternative_count,
    get_distance_at,
    get_duration_at,
    get_geometry_polyline,
    get_geometry_coordinate_count,
    get_geometry_coordinate,
    get_waypoint_count,
    get_waypoint_coordinate,
    get_waypoint_name,
    get_leg_count,
    get_step_count,
    get_step_distance,
    get_step_duration,
    get_step_instruction

end # module Routes
