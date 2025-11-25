"""
Tile service wrapper.
"""
module Tile

using ..CWrapper
using ..Error: with_error, error_pointer
import ..Config: OSRM
import ..Params: TileParams

"""
    TileResponse

Owns the libosrmc tile response pointer and ensures it gets freed when the Julia
object is garbage collected.
"""
mutable struct TileResponse
    ptr::Ptr{Cvoid}

    function TileResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TileResponse from NULL pointer")
        response = new(ptr)
        finalizer(response) do r
            if r.ptr != C_NULL
                CWrapper.osrmc_tile_response_destruct(r.ptr)
                r.ptr = C_NULL
            end
        end
        return response
    end
end

"""
    size(response::TileResponse) -> Int

Get the raw byte size of the vector tile payload.
"""
size(response::TileResponse) =
    Int(with_error() do err
        CWrapper.osrmc_tile_response_size(response.ptr, error_pointer(err))
    end)

"""
    data(response::TileResponse) -> Vector{UInt8}

Copy the binary vector-tile payload into a Julia-owned buffer.
"""
function data(response::TileResponse)
    len_ref = Ref{Csize_t}(0)
    ptr = with_error() do err
        CWrapper.osrmc_tile_response_data(response.ptr, Base.unsafe_convert(Ptr{Csize_t}, len_ref), error_pointer(err))
    end
    len = Int(len_ref[])
    len == 0 && return UInt8[]
    buffer = Vector{UInt8}(undef, len)
    unsafe_copyto!(pointer(buffer), Ptr{UInt8}(ptr), len)
    return buffer
end

"""
    tile(osrm::OSRM, params::TileParams) -> TileResponse

Query the Tile service and return a response object.
"""
function tile(osrm::OSRM, params::TileParams)
    ptr = with_error() do err
        CWrapper.osrmc_tile(osrm.ptr, params.ptr, error_pointer(err))
    end
    return TileResponse(ptr)
end

end # module Tile
