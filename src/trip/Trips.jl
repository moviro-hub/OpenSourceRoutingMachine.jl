module Trips

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
    as_cstring, as_cstring_or_null,
    # finalize helpers
    finalize,
    # response deserializers
    as_struct

import ..OpenSourceRoutingMachine:
    # parameters
    set_roundtrip!,
    set_source!,
    set_destination!,
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

"""
    TripSource

Selects the source location strategy for trip queries (`trip_source_any_source`, `trip_source_first`).
"""
@cenum(
    TripSource::Int32, begin
        trip_source_any_source = 0
        trip_source_first = 1
    end
)

"""
    TripDestination

Selects the destination location strategy for trip queries (`trip_destination_any_destination`, `trip_destination_last`).
"""
@cenum(
    TripDestination::Int32, begin
        trip_destination_any_destination = 0
        trip_destination_last = 1
    end
)

include("response.jl")
include("params.jl")

"""
    trip_response(osrm::OSRM, params::TripParams) -> TripResponse

Calls the libosrm Trip module and returns the response as a TripResponse object.
"""
function trip_response(osrm::OSRM, params::TripParams)::TripResponse
    ptr = with_error() do err
        ccall((:osrmc_trip, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = TripResponse(ptr)
    return response
end

"""
    trip(osrm::OSRM, params::TripParams) -> Union{FBResult, Vector{UInt8}}

Calls the libosrm Trip module and returns the response as FlatBuffers.
"""
function trip(osrm::OSRM, params::TripParams; deserialize::Bool = true)
    response = trip_response(osrm, params)
    # Always use zero-copy FlatBuffer transfer
    fb_data = get_flatbuffer(response)
    return deserialize ? as_struct(fb_data) : fb_data
end

## Parameter setter exports
export
    TripParams,
    TripSource,
    TripDestination,
    set_steps!,
    set_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    set_roundtrip!,
    set_source!,
    set_destination!,
    clear_waypoints!,
    add_waypoint!,
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
export trip_response

## Response getter exports
export TripResponse,
    get_flatbuffer

# compute trip result exports
export trip

end # module Trips
