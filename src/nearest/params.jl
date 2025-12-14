@inline function nearest_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_nearest_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    NearestParams()

Provides a reusable parameter block for Nearest requests so iterative proximity
searches do not constantly rebuild C structs.
"""
mutable struct NearestParams
    ptr::Ptr{Cvoid}

    function NearestParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_nearest_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        finalize(params, nearest_params_destruct)
        return params
    end
end

"""
    set_number_of_results!(params::NearestParams, n)

Caps how many candidates OSRM should return, keeping proximity lookups bounded
for UIs that only display the top-k matches.
"""
function set_number_of_results!(params::NearestParams, n::Integer)
    with_error() do error_ptr
        ccall((:osrmc_nearest_params_set_number_of_results, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(n), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_coordinate!(params::NearestParams, coord::Position)

Append a query coordinate for the Nearest search in `(lon, lat)` order.
"""
function add_coordinate!(params::NearestParams, coord::Position)
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
    add_coordinate_with!(params::NearestParams, coord::Position, radius, bearing, range)

Append a coordinate together with radius and bearing hints to influence how
OSRM snaps to the road network when finding nearest points.
"""
function add_coordinate_with!(params::NearestParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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
    set_hint!(params::NearestParams, coordinate_index, hint)

Attach a precomputed hint for a candidate so repeated Nearest queries can skip
full snapping work.
"""
function set_hint!(params::NearestParams, coordinate_index::Integer, hint::AbstractString)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall(
            (:osrmc_params_set_hint, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Cstring, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            Base.unsafe_convert(Cstring, Base.cconvert(Cstring, hint)),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

"""
    set_radius!(params::NearestParams, coordinate_index, radius)

Set a per-coordinate snapping radius in meters for Nearest lookups.
"""
function set_radius!(params::NearestParams, coordinate_index::Integer, radius::Real)
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
    set_bearing!(params::NearestParams, coordinate_index, value, range)

Constrain Nearest snapping by heading, preferring candidates aligned with the
current direction of travel.
"""
function set_bearing!(params::NearestParams, coordinate_index::Integer, value::Integer, range::Integer)
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
    set_approach!(params::NearestParams, coordinate_index, approach)

Control which side of the road to approach when evaluating nearest candidates.
"""
function set_approach!(params::NearestParams, coordinate_index::Integer, approach::Approach)
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
    add_exclude!(params::NearestParams, profile)

Exclude traffic classes (e.g. `"toll"`, `"ferry"`) when searching for nearest
edges.
"""
function add_exclude!(params::NearestParams, profile::AbstractString)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_exclude, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Base.unsafe_convert(Cstring, Base.cconvert(Cstring, profile)),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

"""
    set_generate_hints!(params::NearestParams, on)

Toggle generation of hints for Nearest results so callers can reuse them for
follow-up queries.
"""
function set_generate_hints!(params::NearestParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_skip_waypoints!(params::NearestParams, on)

Ask OSRM to omit waypoint objects from the response to keep Nearest payloads
minimal.
"""
function set_skip_waypoints!(params::NearestParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_snapping!(params::NearestParams, snapping)

Configure the snapping strategy for Nearest requests using the `Snapping` enum.
"""
function set_snapping!(params::NearestParams, snapping::Snapping)
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
