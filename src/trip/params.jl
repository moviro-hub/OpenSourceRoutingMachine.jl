@inline function trip_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_trip_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TripParams()

Encapsulates trip-specific toggles like roundtrips and fixed endpoints, letting
you experiment with tour planning without reinitializing libosrm state.
"""
mutable struct TripParams
    ptr::Ptr{Cvoid}

    function TripParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_trip_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        Utils.finalize(params, trip_params_destruct)
        return params
    end
end

"""
    add_roundtrip!(params::TripParams, on)

Controls whether OSRM should force start and end to coincide, critical when
optimizing delivery tours vs. point-to-point trips.
"""
function add_roundtrip!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_add_roundtrip, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, as_cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_source!(params::TripParams, source)

Fixes the trip's start behavior (first/last/any), ensuring OSRM respects
business constraints like fixed depots.
"""
function add_source!(params::TripParams, source::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_add_source, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(source), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_destination!(params::TripParams, destination)

Same as `add_source!` but for the tour endpoint so depot returns and open tours
can be modeled explicitly.
"""
function add_destination!(params::TripParams, destination::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_add_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(destination), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    clear_waypoints!(params::TripParams)

Removes any previously selected fixed stops so you can iterate on waypoint
ordering without reallocating params.
"""
function clear_waypoints!(params::TripParams)
    ccall((:osrmc_trip_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params.ptr)
    return nothing
end

"""
    add_waypoint!(params::TripParams, index)

Locks a coordinate index as a fixed visit, which is necessary when mixing
mandatory stops with OSRM's optimized order.
"""
function add_waypoint!(params::TripParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_trip_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function add_coordinate!(params::TripParams, coord::LatLon)
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

function add_coordinate_with!(params::TripParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
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

function set_hint!(params::TripParams, coordinate_index::Integer, hint::AbstractString)
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

function set_radius!(params::TripParams, coordinate_index::Integer, radius::Real)
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

function set_bearing!(params::TripParams, coordinate_index::Integer, value::Integer, range::Integer)
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

function set_approach!(params::TripParams, coordinate_index::Integer, approach)
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

function add_exclude!(params::TripParams, profile::AbstractString)
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

function set_generate_hints!(params::TripParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_skip_waypoints!(params::TripParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_snapping!(params::TripParams, snapping)
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

function set_format!(params::TripParams, format)
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
