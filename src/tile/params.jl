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
        finalize(params, tile_params_destruct)
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

"""
    add_coordinate!(params::TileParams, coord::Position)

Attach a single coordinate (usually the tile center) to the Tile request.
"""
function add_coordinate!(params::TileParams, coord::Position)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cdouble, Cdouble, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cdouble(coord.longitude),
            Cdouble(coord.latitude),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

"""
    add_coordinate_with!(params::TileParams, coord::Position, radius, bearing, range)

Attach a coordinate together with snapping hints so OSRM can refine which tile
segment to return.
"""
function add_coordinate_with!(params::TileParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate_with, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cdouble, Cdouble, Cdouble, Cint, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cdouble(coord.longitude),
            Cdouble(coord.latitude),
            Cdouble(radius),
            Cint(bearing),
            Cint(range),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

"""
    set_hint!(params::TileParams, coordinate_index, hint)

Provide a precomputed hint for a coordinate to avoid full snapping work when
fetching tiles repeatedly.
"""
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

"""
    set_radius!(params::TileParams, coordinate_index, radius)

Override the default snapping radius for a specific tile coordinate.
"""
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

"""
    set_bearing!(params::TileParams, coordinate_index, value, range)

Constrain tile snapping by heading so vector tiles line up with the travel
direction.
"""
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

"""
    set_approach!(params::TileParams, coordinate_index, approach)

Control which side of the road a tile coordinate should approach from.
"""
function set_approach!(params::TileParams, coordinate_index::Integer, approach::Approach)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    code = Cint(approach)
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

"""
    add_exclude!(params::TileParams, profile)

Exclude traffic classes when generating tiles, mirroring other services.
"""
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

"""
    set_generate_hints!(params::TileParams, on)

Toggle generation of reusable hints for tile coordinates.
"""
function set_generate_hints!(params::TileParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_skip_waypoints!(params::TileParams, on)

Ask OSRM to omit waypoints from the Tile response metadata to keep payloads
minimal.
"""
function set_skip_waypoints!(params::TileParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_snapping!(params::TileParams, snapping)

Configure snapping strategy for tile coordinates using the `Snapping` enum.
"""
function set_snapping!(params::TileParams, snapping::Snapping)
    code = Cint(snapping)
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
