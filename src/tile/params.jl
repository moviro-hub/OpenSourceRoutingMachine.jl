@inline function tile_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_tile_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TileParams()

Reusable parameter block for Tile requests.
"""
mutable struct TileParams
    ptr::Ptr{Cvoid}

    function TileParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_tile_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        finalize(params, tile_params_destruct)
        return params
    end
end

"""
    set_x!(params::TileParams, x)

Set tile X coordinate.
"""
function set_x!(params::TileParams, x::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_x, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(x), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_x(params::TileParams) -> Int

Get tile X coordinate.
"""
function get_x(params::TileParams)
    out_x = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_get_x, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_x, error_pointer(error_ptr))
        nothing
    end
    return Int(out_x[])
end

"""
    set_y!(params::TileParams, y)

Set tile Y coordinate.
"""
function set_y!(params::TileParams, y::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_y, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(y), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_y(params::TileParams) -> Int

Get tile Y coordinate.
"""
function get_y(params::TileParams)
    out_y = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_get_y, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_y, error_pointer(error_ptr))
        nothing
    end
    return Int(out_y[])
end

"""
    set_z!(params::TileParams, z)

Set tile zoom level.
"""
function set_z!(params::TileParams, z::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_z, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(z), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_z(params::TileParams) -> Int

Get tile zoom level.
"""
function get_z(params::TileParams)
    out_z = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_get_z, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_z, error_pointer(error_ptr))
        nothing
    end
    return Int(out_z[])
end
