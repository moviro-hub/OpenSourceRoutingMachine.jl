module Nearests

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, distance, set_number_of_results!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat
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

export
    NearestResponse,
    NearestParams,
    nearest,
    as_json,
    count,
    latitude,
    longitude,
    name,
    distance,
    hint,
    set_number_of_results!

end # module Nearests
