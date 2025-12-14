module Nearests

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
    # error helpers
    with_error, error_pointer, check_error,
    # string helpers
    as_cstring, as_cstring_or_null,
    # finalize helpers
    finalize,
    # response deserializers
    as_struct

import ..OpenSourceRoutingMachine:
    # parameters
    set_number_of_results!,
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

import Base: count

include("response.jl")
include("params.jl")

"""
    nearest_response(osrm::OSRM, params::NearestParams) -> NearestResponse

Calls the libosrm Nearest module and returns the response as a NearestResponse object.
"""
function nearest_response(osrm::OSRM, params::NearestParams)::NearestResponse
    ptr = with_error() do err
        ccall((:osrmc_nearest, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = NearestResponse(ptr)
    return response
end

"""
    nearest(osrm::OSRM, params::NearestParams) -> Union{FBResult, Vector{UInt8}}

Calls the libosrm Nearest module and returns the response as FlatBuffers.
"""
function nearest(osrm::OSRM, params::NearestParams; deserialize::Bool = true)
    response = nearest_response(osrm, params)
    # Always use zero-copy FlatBuffer transfer
    fb_data = get_flatbuffer(response)
    return deserialize ? as_struct(fb_data) : fb_data
end

## Parameter setter exports
export
    NearestParams,
    set_number_of_results!,
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
export nearest_response

## Response getter exports
export NearestResponse,
    get_flatbuffer

# compute nearest result exports
export nearest

end # module Nearests
