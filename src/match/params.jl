@inline function match_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_match_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    MatchParams()

Holds the map-matching options (timestamps, gap handling, etc.) so GPS trace
processing can mutate a single object across requests.
"""
mutable struct MatchParams
    ptr::Ptr{Cvoid}

    function MatchParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_match_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        Utils.finalize(params, match_params_destruct)
        return params
    end
end

"""
    add_steps!(params::MatchParams, on)

Mirrors the Route behavior so callers can request per-step guidance while
running map-matching.
"""
function add_steps!(params::MatchParams, on::Bool)
    ccall((:osrmc_match_params_add_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

"""
    add_alternatives!(params::MatchParams, on)

Allows the matcher to keep alternate routes which helps downstream quality
checks decide when to fall back.
"""
function add_alternatives!(params::MatchParams, on::Bool)
    ccall((:osrmc_match_params_add_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

"""
    set_geometries!(params::MatchParams, geometries)
"""
function set_geometries!(params::MatchParams, geometries::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(geometries), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_overview!(params::MatchParams, overview)
"""
function set_overview!(params::MatchParams, overview::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(overview), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_continue_straight!(params::MatchParams, on)
"""
function set_continue_straight!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, as_cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_number_of_alternatives!(params::MatchParams, count)
"""
function set_number_of_alternatives!(params::MatchParams, count::Integer)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(count), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_annotations!(params::MatchParams, annotations)
"""
function set_annotations!(params::MatchParams, annotations::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(annotations), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_waypoint!(params::MatchParams, index)
"""
function add_waypoint!(params::MatchParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_match_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    clear_waypoints!(params::MatchParams)
"""
function clear_waypoints!(params::MatchParams)
    ccall((:osrmc_match_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params.ptr)
    return nothing
end

"""
    add_timestamp!(params::MatchParams, timestamp)

Feeds per-point timestamps so OSRM can respect vehicle speed between samples,
which improves matching on sparse GPS data.
"""
function add_timestamp!(params::MatchParams, timestamp::Integer)
    with_error() do error_ptr
        ccall((:osrmc_match_params_add_timestamp, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(timestamp), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_gaps!(params::MatchParams, gaps)

Tells OSRM how to treat missing samples (split vs. ignore), letting analytics
pipelines encode their tolerance for GPS outages.
"""
function set_gaps!(params::MatchParams, gaps::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_gaps, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(gaps), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_tidy!(params::MatchParams, on)

Requests OSRM to drop redundant tracepoints, which reduces downstream storage
when high-frequency logs are matched.
"""
function set_tidy!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_tidy, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, as_cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function add_coordinate!(params::MatchParams, coord::LatLon)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cdouble, Cdouble, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cdouble(coord.lon),
            Cdouble(coord.lat),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function add_coordinate_with!(params::MatchParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_add_coordinate_with, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Cdouble, Cdouble, Cdouble, Cint, Cint, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Cdouble(coord.lon),
            Cdouble(coord.lat),
            Cdouble(radius),
            Cint(bearing),
            Cint(range),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function set_hint!(params::MatchParams, coordinate_index::Integer, hint::AbstractString)
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

function set_radius!(params::MatchParams, coordinate_index::Integer, radius::Real)
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

function set_bearing!(params::MatchParams, coordinate_index::Integer, value::Integer, range::Integer)
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

function set_approach!(params::MatchParams, coordinate_index::Integer, approach)
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

function add_exclude!(params::MatchParams, profile::AbstractString)
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

function set_generate_hints!(params::MatchParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_skip_waypoints!(params::MatchParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_snapping!(params::MatchParams, snapping)
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
