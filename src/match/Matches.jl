module Matches

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, distance, add_timestamp!, set_gaps!, set_tidy!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat
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

export
    MatchResponse,
    MatchParams,
    match,
    as_json,
    route_count,
    tracepoint_count,
    route_distance,
    route_duration,
    route_confidence,
    tracepoint_latitude,
    tracepoint_longitude,
    tracepoint_is_null,
    add_timestamp!,
    set_gaps!,
    set_tidy!

end # module Matches
