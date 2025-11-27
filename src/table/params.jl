@inline function table_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_table_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TableParams()

Wraps libosrmc's table parameter object, keeping the GC responsible for cleanup
while you build many-to-many queries in Julia.
"""
mutable struct TableParams
    ptr::Ptr{Cvoid}

    function TableParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_table_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        Utils.finalize(params, table_params_destruct)
        return params
    end
end

"""
    add_source!(params::TableParams, index)

Selects which coordinate acts as a source so you can build sparse matrices
without reallocating params for each subset.
"""
function add_source!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_table_params_add_source, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_destination!(params::TableParams, index)

Same as `add_source!` but for destinations, enabling asymmetric matrices when
needed.
"""
function add_destination!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_table_params_add_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_annotations_mask!(params::TableParams, mask)

Restricts OSRM's matrix annotations (duration, distance, etc.) so data exports
only include the metrics you plan to consume.
"""
function set_annotations_mask!(params::TableParams, mask::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_annotations_mask, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring(mask), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_fallback_speed!(params::TableParams, speed)

Defines the heuristic speed OSRM should use when a cell is unreachable, letting
you distinguish true disconnections from missing data.
"""
function set_fallback_speed!(params::TableParams, speed::Real)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_fallback_speed, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params.ptr, Cdouble(speed), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_fallback_coordinate_type!(params::TableParams, coord_type)

Controls whether fallback results snap to input coordinates or to network
snaps, ensuring downstream code interprets placeholders correctly.
"""
function set_fallback_coordinate_type!(params::TableParams, coord_type::Union{AbstractString, Nothing})
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_fallback_coordinate_type, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params.ptr, as_cstring_or_null(coord_type), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    set_scale_factor!(params::TableParams, factor)

Scales unreachable entries so visualization layers can downplay them rather
than treating them as raw infinity.
"""
function set_scale_factor!(params::TableParams, factor::Real)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_scale_factor, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params.ptr, Cdouble(factor), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function add_coordinate!(params::TableParams, coord::LatLon)
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

function add_coordinate_with!(params::TableParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
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

function set_hint!(params::TableParams, coordinate_index::Integer, hint::AbstractString)
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

function set_radius!(params::TableParams, coordinate_index::Integer, radius::Real)
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

function set_bearing!(params::TableParams, coordinate_index::Integer, value::Integer, range::Integer)
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

function set_approach!(params::TableParams, coordinate_index::Integer, approach)
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

function add_exclude!(params::TableParams, profile::AbstractString)
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

function set_generate_hints!(params::TableParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_skip_waypoints!(params::TableParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, as_cint(on))
    return nothing
end

function set_snapping!(params::TableParams, snapping)
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

function set_format!(params::TableParams, format)
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
