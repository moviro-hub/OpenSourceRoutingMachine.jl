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
        finalize(params, table_params_destruct)
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
    set_annotations!(params::TableParams, annotations::TableAnnotations)

Restricts OSRM's matrix annotations (duration, distance, etc.) so data exports
only include the metrics you plan to consume.
"""
function set_annotations!(params::TableParams, annotations::TableAnnotations)
    code = Cint(annotations)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
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
    set_fallback_coordinate_type!(params::TableParams, coord_type::TableFallbackCoordinate)

Controls whether fallback results snap to input coordinates or to network
snaps, ensuring downstream code interprets placeholders correctly.
"""
function set_fallback_coordinate_type!(params::TableParams, coord_type::TableFallbackCoordinate)
    code = Cint(coord_type)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_fallback_coordinate_type, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
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

"""
    add_coordinate!(params::TableParams, coord::Position)

Append a coordinate in `(lon, lat)` order to the current Table request.
"""
function add_coordinate!(params::TableParams, coord::Position)
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
    add_coordinate_with!(params::TableParams, coord::Position, radius, bearing, range)

Append a coordinate with radius and bearing hints so OSRM can snap more
accurately when building distance/duration matrices.
"""
function add_coordinate_with!(params::TableParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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
    set_hint!(params::TableParams, coordinate_index, hint)

Attach a precomputed hint to a matrix coordinate to speed up repeated queries
over the same snapped locations.
"""
function set_hint!(params::TableParams, coordinate_index::Integer, hint::AbstractString)
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
    set_radius!(params::TableParams, coordinate_index, radius)

Override the default snapping radius for a specific coordinate in the matrix.
"""
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

"""
    set_bearing!(params::TableParams, coordinate_index, value, range)

Constrain snapping using a heading and allowed deviation so origins/destinations
prefer edges aligned with the current travel direction.
"""
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

"""
    set_approach!(params::TableParams, coordinate_index, approach)

Control which side of the road a vehicle should approach for a particular
matrix coordinate.
"""
function set_approach!(params::TableParams, coordinate_index::Integer, approach::Approach)
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
    add_exclude!(params::TableParams, profile)

Exclude traffic classes (for example `"toll"` or `"ferry"`) from matrix
computations.
"""
function add_exclude!(params::TableParams, profile::AbstractString)
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
    set_generate_hints!(params::TableParams, on)

Toggle generation of reusable hints for all snapped coordinates in the table.
"""
function set_generate_hints!(params::TableParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_skip_waypoints!(params::TableParams, on)

Ask OSRM to omit waypoints from the Table response to reduce payload size.
"""
function set_skip_waypoints!(params::TableParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    set_snapping!(params::TableParams, snapping)

Configure how aggressively OSRM should snap matrix coordinates to the road
network using the `Snapping` enum.
"""
function set_snapping!(params::TableParams, snapping::Snapping)
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
