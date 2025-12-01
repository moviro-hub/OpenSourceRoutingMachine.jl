module Trips

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, distance, duration, as_json, libosrmc,
    add_roundtrip!, add_source!, add_destination!, add_waypoint!, clear_waypoints!,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat

include("response.jl")
include("params.jl")

"""
    trip(osrm::OSRM, params::TripParams) -> TripResponse

Query the Trip service and return a response object.
"""
function trip(osrm::OSRM, params::TripParams)
    ptr = with_error() do err
        ccall((:osrmc_trip, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return TripResponse(ptr)
end

## Parameter exports
export
    TripParams,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_roundtrip!,
    add_source!,
    add_destination!,
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
    set_snapping!,
    set_format!

## Response exports
export
    TripResponse,
    trip,
    as_json,
    distance,
    duration,
    waypoint_count,
    waypoint_latitude,
    waypoint_longitude

end # module Trips
