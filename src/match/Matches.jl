module Matches

using CEnum
using ..OpenSourceRoutingMachine:
    # modules
    libosrmc,
    # types
    OSRM,
    Position,
    OSRMError,
    # enums
    Approach,
    Snapping,
    Overview,
    Annotations,
    Geometries,
    # error helpers
    with_error, error_pointer, check_error,
    # string helpers
    as_cstring_or_null,
    # finalize helpers
    finalize,
    # response deserializers
    as_struct

import ..OpenSourceRoutingMachine:
    # parameters
    add_timestamp!,
    set_gaps!,
    set_tidy!,
    set_steps!,
    set_alternatives!,
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

import Base: match

"""
    MatchGaps

Controls how OSRM handles gaps in map matching traces (`MATCH_GAPS_SPLIT`, `MATCH_GAPS_IGNORE`).
"""
@cenum(
    MatchGaps::Int32, begin
        MATCH_GAPS_SPLIT = 0
        MATCH_GAPS_IGNORE = 1
    end
)

include("response.jl")
include("params.jl")

"""
    match_response(osrm::OSRM, params::MatchParams) -> MatchResponse

Calls the libosrm Match module and returns the response as a MatchResponse object.
"""
function match_response(osrm::OSRM, params::MatchParams)::MatchResponse
    ptr = with_error() do err
        ccall((:osrmc_match, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = MatchResponse(ptr)
    return response
end

"""
    match(osrm::OSRM, params::MatchParams) -> Union{FBResult, Vector{UInt8}}

Calls the libosrm Match module and returns the response as FlatBuffers.
"""
function match(osrm::OSRM, params::MatchParams; deserialize::Bool = true)
    response = match_response(osrm, params)
    # Always use zero-copy FlatBuffer transfer
    fb_data = get_flatbuffer(response)
    return deserialize ? as_struct(fb_data) : fb_data
end

## Parameter setter exports
export
    MatchParams,
    MatchGaps,
    set_steps!,
    set_alternatives!,
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

## compute response exports
export match_response

## Response getter exports
export MatchResponse,
    get_flatbuffer

# compute match result exports
export match

end # module Matches
