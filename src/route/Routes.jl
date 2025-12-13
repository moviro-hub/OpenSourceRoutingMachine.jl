module Routes

using FlatBuffers
using ..OpenSourceRoutingMachine: with_error, error_pointer, check_error, as_cstring, as_cstring_or_null, deserialize
import ..OpenSourceRoutingMachine:
    OSRM,
    get_json,
    libosrmc,
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
    Position,
    Approach,
    Snapping,
    Geometries,
    Overview,
    Annotations,
    OutputFormat,
    finalize,
    as_string
using JSON: JSON

include("response.jl")
include("params.jl")

"""
    route_response(osrm::OSRM, params::RouteParams) -> RouteResponse

Calls the libosrm Route module and returns the response as a RouteResponse object.
"""
function route_response(osrm::OSRM, params::RouteParams)::RouteResponse
    ptr = with_error() do err
        ccall((:osrmc_route, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = RouteResponse(ptr)
    return response
end

"""
    route(osrm::OSRM, params::RouteParams) -> Union{String, Vector{UInt8}}

Calls the libosrm Route module and returns the response as either JSON or FlatBuffers.
"""
function route(osrm::OSRM, params::RouteParams; deserialize::Bool = true)
    response = route_response(osrm, params)
    format = get_format(response)
    if format == output_format_json
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
    RouteParams,
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
export route_response

## Response getter exports
export RouteResponse,
    get_format,
    get_json,
    get_flatbuffer

# compute route result exports
export route

end # module Routes
