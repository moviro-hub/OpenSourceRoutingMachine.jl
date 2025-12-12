module Nearests

using ..OpenSourceRoutingMachine: with_error, error_pointer, as_cstring, as_cstring_or_null, deserialize
import ..OpenSourceRoutingMachine:
    OSRM, set_number_of_results!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, Position, Approach, Snapping, OutputFormat, finalize, as_string
import Base: count
using JSON: JSON

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
    nearest(osrm::OSRM, params::NearestParams) -> Union{String, Vector{UInt8}}

Calls the libosrm Nearest module and returns the response as either JSON or FlatBuffers.
"""
function nearest(osrm::OSRM, params::NearestParams; deserialize::Bool = true)
    response = nearest_response(osrm, params)
    format = get_format(response)
    if format == OutputFormat(0)  # json
        if deserialize
            return JSON.parse(get_json(response))
        else
            return get_json(response)
        end
    elseif format == OutputFormat(1)  # flatbuffers
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
    NearestParams,
    set_format!,
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
  get_format,
  get_json,
  get_flatbuffer

# compute nearest result exports
export nearest

end # module Nearests
