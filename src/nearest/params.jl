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
        Utils.finalize(params, nearest_params_destruct)
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
        ccall((:osrmc_nearest_set_number_of_results, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(n), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function add_coordinate!(params::NearestParams, coord::LatLon)
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

function add_coordinate_with!(params::NearestParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
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

function set_hint!(params::NearestParams, coordinate_index::Integer, hint::AbstractString)
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

function set_approach!(params::NearestParams, coordinate_index::Integer, approach)
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

function add_exclude!(params::NearestParams, profile::AbstractString)
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

function set_generate_hints!(params::NearestParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_skip_waypoints!(params::NearestParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_snapping!(params::NearestParams, snapping)
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

function set_format!(params::NearestParams, format)
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
