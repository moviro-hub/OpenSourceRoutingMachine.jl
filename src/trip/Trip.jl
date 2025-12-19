module Trip

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

Selects the source location strategy for trip queries (`TRIP_SOURCE_ANY_SOURCE`, `TRIP_SOURCE_FIRST`).
"""
@cenum(
    TripSource::Int32, begin
        TRIP_SOURCE_ANY_SOURCE = 0
        TRIP_SOURCE_FIRST = 1
    end
)

"""
    TripDestination

Selects the destination location strategy for trip queries (`TRIP_DESTINATION_ANY_DESTINATION`, `TRIP_DESTINATION_LAST`).
"""
@cenum(
    TripDestination::Int32, begin
        TRIP_DESTINATION_ANY_DESTINATION = 0
        TRIP_DESTINATION_LAST = 1
    end
)

include("response.jl")
include("params.jl")

"""
    trip_response(osrm::OSRM, params::TripParams) -> TripResponse

Call Trip service and return response object.
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

Call Trip service and return FlatBuffers response.
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

## Parameter getter exports
export
    get_steps,
    get_alternatives,
    get_geometries,
    get_overview,
    get_continue_straight,
    get_number_of_alternatives,
    get_annotations,
    get_roundtrip,
    get_source,
    get_destination,
    get_waypoints,
    get_coordinates,
    get_hints,
    get_radii,
    get_bearings,
    get_approaches,
    get_coordinates_with,
    get_excludes,
    get_generate_hints,
    get_skip_waypoints,
    get_snapping

## compute response exports
export trip_response

## Response getter exports
export TripResponse,
    get_flatbuffer

# compute trip result exports
export trip

end # module Trip
