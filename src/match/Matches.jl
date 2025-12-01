module Matches

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, get_distance, add_timestamp!, set_gaps!, set_tidy!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, LatLon, Approach, Snapping
import Base: match

include("response.jl")
include("params.jl")

"""
    match(osrm::OSRM, params::MatchParams) -> MatchResponse

Extends `Base.match` so callers can invoke OSRM's native matcher directly and
receive a typed response without HTTP hops.
"""
function match(osrm::OSRM, params::MatchParams)
    ptr = with_error() do err
        ccall((:osrmc_match, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return MatchResponse(ptr)
end

## Parameter exports
export
    MatchParams,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!,
    add_timestamp!,
    set_gaps!,
    set_tidy!,
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
    MatchResponse,
    match,
    as_json,
    get_route_count,
    get_route_distance,
    get_route_duration,
    get_route_confidence,
    get_tracepoint_count,
    get_tracepoint_coordinate,
    get_tracepoint_is_null

end # module Matches
