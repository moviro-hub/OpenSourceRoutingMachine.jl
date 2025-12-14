@inline function route_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_route_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    RouteParams()

Owns the native route parameter handle so callers can build requests without
allocating temporary structs for every query.
"""
mutable struct RouteParams
    ptr::Ptr{Cvoid}

    function RouteParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_route_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        finalize(params, route_params_destruct)
        return params
    end
end

"""
    set_steps!(params::RouteParams, on)

Requests OSRM to emit per-step instructions, which is necessary when building
turn-by-turn guidance layers.
"""
function set_steps!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_alternatives!(params::RouteParams, on)

Signals that clients plan to evaluate multiple candidate routes, so OSRM keeps
producing alternates instead of pruning early.
"""
function set_alternatives!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_geometries!(params::RouteParams, geometries::Geometries)

Choose between polyline encodings to match downstream consumers (e.g. GeoJSON
vs. polyline6) without rebuilding the request object.
"""
function set_geometries!(params::RouteParams, geometries::Geometries)
    code = Cint(geometries)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_overview!(params::RouteParams, overview::Overview)

Controls how much geometry OSRM should include (full, simplified, or none),
which directly impacts payload size.
"""
function set_overview!(params::RouteParams, overview::Overview)
    code = Cint(overview)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_continue_straight!(params::RouteParams, on)

Prevents OSRM from suggesting hairpins at roundabouts when the application
requires staying aligned with the current heading.
"""
function set_continue_straight!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_number_of_alternatives!(params::RouteParams, count)

Caps how many alternates OSRM should compute so you can bound latency for
interactive use cases.
"""
function set_number_of_alternatives!(params::RouteParams, count::Integer)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(count), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_annotations!(params::RouteParams, annotations::Annotations)

Asks OSRM to emit per-edge metadata (speed, duration, etc.) so analytics jobs
can inspect costs at a finer granularity.
"""
function set_annotations!(params::RouteParams, annotations::Annotations)
    code = Cint(annotations)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_waypoint!(params::RouteParams, index)

Marks the current coordinate as a waypoint so OSRM reports where routes diverge
or visit intermediate stops.
"""
function add_waypoint!(params::RouteParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_route_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    clear_waypoints!(params::RouteParams)

Resets waypoint selections in-place, letting you reuse the same parameter block
for multiple experiments without reconstructing coordinates.
"""
function clear_waypoints!(params::RouteParams)
    ccall((:osrmc_route_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params.ptr)
    return nothing
end

"""
    add_coordinate!(params::RouteParams, coord::Position)

Append a coordinate to the current request in `(lon, lat)` order, reusing the
same `RouteParams` across multiple calls.
"""
function add_coordinate!(params::RouteParams, coord::Position)
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
    add_coordinate_with!(params::RouteParams, coord::Position, radius, bearing, range)

Append a coordinate together with search radius and bearing hints so OSRM can
snap more accurately to the road network.
"""
function add_coordinate_with!(params::RouteParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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
    set_hint!(params::RouteParams, coordinate_index, hint)

Attach a precomputed hint to a coordinate to speed up subsequent queries that
reuse the same snapped location.
"""
function set_hint!(params::RouteParams, coordinate_index::Integer, hint::AbstractString)
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
    set_radius!(params::RouteParams, coordinate_index, radius)

Set a per-coordinate search radius in meters, relaxing or tightening how far
OSRM may move the point to find a routable edge.
"""
function set_radius!(params::RouteParams, coordinate_index::Integer, radius::Real)
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
    set_bearing!(params::RouteParams, coordinate_index, value, range)

Constrain snapping using a heading and allowed deviation range so OSRM prefers
edges aligned with the current travel direction.
"""
function set_bearing!(params::RouteParams, coordinate_index::Integer, value::Integer, range::Integer)
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
    set_approach!(params::RouteParams, coordinate_index, approach::Approach)

Control whether vehicles should approach waypoints from the curb, be
unrestricted, or use the opposite side where supported.
"""
function set_approach!(params::RouteParams, coordinate_index::Integer, approach::Approach)
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
    add_exclude!(params::RouteParams, profile)

Exclude traffic classes (e.g. `"toll"`, `"ferry"`) from consideration when
computing routes.
"""
function add_exclude!(params::RouteParams, profile::AbstractString)
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
    set_generate_hints!(params::RouteParams, on)

Ask OSRM to emit reusable hints for snapped coordinates, which can be cached by
clients to speed up future queries.
"""
function set_generate_hints!(params::RouteParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_skip_waypoints!(params::RouteParams, on)

Toggle whether OSRM should omit waypoint objects from the response to reduce
payload size when only geometry and metrics are needed.
"""
function set_skip_waypoints!(params::RouteParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_snapping!(params::RouteParams, snapping::Snapping)

Control how aggressively OSRM should snap coordinates to the road network,
using the `Snapping` enum for type safety.
"""
function set_snapping!(params::RouteParams, snapping::Snapping)
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
