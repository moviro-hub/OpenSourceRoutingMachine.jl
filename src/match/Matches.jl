module Matches

using CEnum
using ..OpenSourceRoutingMachine:
    # modules
    libosrmc,
    # types
    OSRM,
    Position,
    # enums
    OutputFormat,
    Approach,
    Snapping,
    Overview,
    Annotations,
    Geometries,
    # enum values
    output_format_json,
    output_format_flatbuffers,
    # error helpers
    with_error, error_pointer, check_error,
    # string helpers
    as_cstring, as_cstring_or_null,
    # finalize helpers
    finalize,
    # data access helpers
    as_string, as_vector,
    # response getters
    get_json, get_flatbuffer,
    # response deserializers
    deserialize

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
    set_snapping!,
    # response getters
    get_json,
    get_flatbuffer

import Base: match
using JSON: JSON

"""
    MatchGaps

Controls how OSRM handles gaps in map matching traces (`match_gaps_split`, `match_gaps_ignore`).
"""
@cenum(
    MatchGaps::Int32, begin
        match_gaps_split = 0
        match_gaps_ignore = 1
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
    match(osrm::OSRM, params::MatchParams) -> Union{String, Vector{UInt8}}

Calls the libosrm Match module and returns the response as either JSON or FlatBuffers.
"""
function match(osrm::OSRM, params::MatchParams; deserialize::Bool = true)
    response = match_response(osrm, params)
    format = get_format(response)
    return if format == output_format_json
        if deserialize
            return JSON.parse(get_json(response))
        else
            return get_json(response)
        end
    elseif format == output_format_flatbuffers
        if deserialize
            return deserialize(get_flatbuffer(response))
        else
            return get_flatbuffer(response)
        end
    else
        error("Invalid output format: $format")
    end
end

## Parameter setter exports
export
    MatchParams,
    MatchGaps,
    set_format!,
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
    get_format,
    get_json,
    get_flatbuffer

# compute match result exports
export match

end # module Matches
