module Tiles

using ..OpenSourceRoutingMachine:
    # modules
    libosrmc,
    # types
    OSRM,
    # error helpers
    with_error, error_pointer, check_error,
    # finalize helpers
    finalize

import ..OpenSourceRoutingMachine:
    # parameters
    set_x!,
    set_y!,
    set_z!

include("response.jl")
include("params.jl")

"""
    tile(osrm::OSRM, params::TileParams) -> TileResponse

Call Tile service and return response object.
"""
function tile(osrm::OSRM, params::TileParams)
    ptr = with_error() do err
        ccall((:osrmc_tile, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return TileResponse(ptr)
end

## Parameter setter exports
export
    TileParams,
    set_x!,
    set_y!,
    set_z!

## Parameter getter exports
export
    get_x,
    get_y,
    get_z

## Response exports
export
    TileResponse,
    get_size,
    get_data

# main function
export tile

end # module Tiles
