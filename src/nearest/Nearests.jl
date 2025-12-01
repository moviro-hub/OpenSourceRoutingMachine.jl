module Nearests

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, get_distance, set_number_of_results!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, LatLon, Approach, Snapping
import Base: count

include("response.jl")
include("params.jl")

"""
    nearest(osrm::OSRM, params::NearestParams) -> NearestResponse

Calls the libosrmc Nearest endpoint directly, avoiding HTTP round-trips.
"""
function nearest(osrm::OSRM, params::NearestParams)
    ptr = with_error() do err
        ccall((:osrmc_nearest, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return NearestResponse(ptr)
end

## Parameter exports
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

## Response exports
export
    NearestResponse,
    as_json,
    get_count,
    get_coordinate,
    get_name,
    get_distance,
    get_hint

end # module Nearests
