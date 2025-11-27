@inline function tile_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_tile_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TileParams()

Keeps an OSRM tile request mutable so map viewers can update XYZ coordinates in
place when users pan the map.
"""
mutable struct TileParams
    ptr::Ptr{Cvoid}

    function TileParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_tile_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        Utils.finalize(params, tile_params_destruct)
        return params
    end
end

"""
    set_x!(params::TileParams, x)

Updates the tile's X index in-place so map renderers can reuse the same request
object while panning horizontally.
"""
function set_x!(params::TileParams, x::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_x, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(x), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_y!(params::TileParams, y)

Companion to `set_x!`; keeps vertical tile changes allocation-free.
"""
function set_y!(params::TileParams, y::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_y, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(y), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_z!(params::TileParams, z)

Adjusts the zoom level without rebuilding the tile request, which keeps map
overlays snappy when zooming.
"""
function set_z!(params::TileParams, z::Integer)
    with_error() do error_ptr
        ccall((:osrmc_tile_params_set_z, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(z), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function add_coordinate!(params::TileParams, coord::LatLon)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cfloat, Cfloat, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cfloat(coord.lon),
            Cfloat(coord.lat),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function add_coordinate_with!(params::TileParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate_with, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cint, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cfloat(coord.lon),
            Cfloat(coord.lat),
            Cfloat(radius),
            Cint(bearing),
            Cint(range),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_hint!(params::TileParams, coordinate_index::Integer, hint::AbstractString)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_hint, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Cstring, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            as_cstring(hint),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_radius!(params::TileParams, coordinate_index::Integer, radius::Real)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_radius, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Cdouble, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            Cdouble(radius),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_bearing!(params::TileParams, coordinate_index::Integer, value::Integer, range::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_bearing, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Cint, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            Cint(value),
            Cint(range),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_approach!(params::TileParams, coordinate_index::Integer, approach)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    code = to_cint(approach, Approach)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_approach, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            code,
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function add_exclude!(params::TileParams, profile::AbstractString)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_exclude, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}),
            params.ptr,
            as_cstring(profile),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_generate_hints!(params::TileParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_skip_waypoints!(params::TileParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_snapping!(params::TileParams, snapping)
    code = to_cint(snapping, Snapping)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_snapping, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            code,
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_format!(params::TileParams, format)
    code = to_cint(format, OutputFormat)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_format, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            code,
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end
