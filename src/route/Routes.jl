module Routes

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
    as_cstring, as_cstring_or_null,
    # finalize helpers
    finalize,
    # response deserializers
    as_struct


import ..OpenSourceRoutingMachine:
    # parameters
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
    route(osrm::OSRM, params::RouteParams) -> Union{FBResult, Vector{UInt8}}

Calls the libosrm Route module and returns the response as FlatBuffers.
"""
function route(osrm::OSRM, params::RouteParams; deserialize::Bool = true)
    response = route_response(osrm, params)
    # Always use zero-copy FlatBuffer transfer
    fb_data = get_flatbuffer(response)
    return deserialize ? as_struct(fb_data) : fb_data
end

## Parameter setter exports
export
    RouteParams,
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
    get_flatbuffer

# compute route result exports
export route

end # module Routes
