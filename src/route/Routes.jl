module Routes

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, distance, duration, as_json, libosrmc,
    add_steps!, add_alternatives!, set_geometries!, set_overview!,
    set_continue_straight!, set_number_of_alternatives!, set_annotations!,
    add_waypoint!, clear_waypoints!,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat

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

export
    RouteResponse,
    RouteParams,
    route,
    as_json,
    distance,
    duration,
    alternative_count,
    distance_at,
    duration_at,
    geometry_polyline,
    geometry_coordinate_count,
    geometry_coordinate_latitude,
    geometry_coordinate_longitude,
    waypoint_count,
    waypoint_latitude,
    waypoint_longitude,
    waypoint_name,
    leg_count,
    step_count,
    step_distance,
    step_duration,
    step_instruction,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!

end # module Routes
