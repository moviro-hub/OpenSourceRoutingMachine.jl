module Tiles

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, set_x!, set_y!, set_z!, libosrmc,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat

include("response.jl")
include("params.jl")

"""
    tile(osrm::OSRM, params::TileParams) -> TileResponse

Query the Tile service and return a response object.
"""
function tile(osrm::OSRM, params::TileParams)
    ptr = with_error() do err
        ccall((:osrmc_tile, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return TileResponse(ptr)
end

## Parameter exports
export
    TileParams,
    set_x!,
    set_y!,
    set_z!,
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
    TileResponse,
    tile,
    data,
    size

end # module Tiles
