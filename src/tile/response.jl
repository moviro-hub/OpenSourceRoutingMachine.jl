"""
    TileResponse

Owns the libosrmc tile response pointer with automatic cleanup.
"""
function _tile_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_tile_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct TileResponse
    ptr::Ptr{Cvoid}

    function TileResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TileResponse from NULL pointer")
        response = new(ptr)
        finalize(response, _tile_response_destruct)
        return response
    end
end

"""
    get_size(response::TileResponse) -> Int

Get vector tile size in bytes.
"""
get_size(response::TileResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_tile_response_size, libosrmc), Csize_t, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    get_data(response::TileResponse) -> Vector{UInt8}

Get vector tile binary data.
"""
function get_data(response::TileResponse)
    len_ref = Ref{Csize_t}(0)
    ptr = with_error() do err
        ccall((:osrmc_tile_response_data, libosrmc), Ptr{Cchar}, (Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Ptr{Cvoid}}), response.ptr, Base.unsafe_convert(Ptr{Csize_t}, len_ref), error_pointer(err))
    end
    if ptr == C_NULL || len_ref[] == 0
        return UInt8[]
    end
    len = Int(len_ref[])
    buffer = Vector{UInt8}(undef, len)
    unsafe_copyto!(pointer(buffer), Ptr{UInt8}(ptr), len)
    return buffer
end
