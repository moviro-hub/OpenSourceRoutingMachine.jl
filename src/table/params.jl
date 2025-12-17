@inline function table_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_table_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TableParams()

Reusable parameter block for Table requests.
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

Mark a coordinate as a source.
"""
function add_source!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_table_params_add_source, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function get_source_count(params::TableParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_source_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_source(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_index = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_table_params_get_source, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Csize_t}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(index - 1),
            out_index,
            error_pointer(error_ptr),
        )
        nothing
    end
    return Int(out_index[]) + 1  # Convert from 0-based to 1-based
end

"""
    get_sources(params::TableParams) -> Vector{Int}

Get all source coordinate indices.
"""
function get_sources(params::TableParams)
    out_sources = Vector{Int}(undef, get_source_count(params))
    for i in 1:get_source_count(params)
        out_sources[i] = get_source(params, i)
    end
    return out_sources
end

"""
    add_destination!(params::TableParams, index)

Mark a coordinate as a destination.
"""
function add_destination!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_table_params_add_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function get_destination_count(params::TableParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_destination_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_destination(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_index = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_table_params_get_destination, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Csize_t}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(index - 1),
            out_index,
            error_pointer(error_ptr),
        )
        nothing
    end
    return Int(out_index[]) + 1  # Convert from 0-based to 1-based
end

"""
    get_destinations(params::TableParams) -> Vector{Int}

Get all destination coordinate indices.
"""
function get_destinations(params::TableParams)
    out_destinations = Vector{Int}(undef, get_destination_count(params))
    for i in 1:get_destination_count(params)
        out_destinations[i] = get_destination(params, i)
    end
    return out_destinations
end

"""
    set_annotations!(params::TableParams, annotations::TableAnnotations)

Set annotation flags (duration, distance, etc.).
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
    get_annotations(params::TableParams) -> TableAnnotations

Get annotation flags.
"""
function get_annotations(params::TableParams)
    out_annotations = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_annotations, error_pointer(error_ptr))
        nothing
    end
    return TableAnnotations(out_annotations[])
end

"""
    set_fallback_speed!(params::TableParams, speed)

Set heuristic speed for unreachable cells.
"""
function set_fallback_speed!(params::TableParams, speed::Real)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_fallback_speed, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params.ptr, Cdouble(speed), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_fallback_speed(params::TableParams) -> Float64

Get heuristic speed for unreachable cells.
"""
function get_fallback_speed(params::TableParams)
    out_speed = Ref{Cdouble}(0.0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_fallback_speed, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cdouble}, Ptr{Ptr{Cvoid}}), params.ptr, out_speed, error_pointer(error_ptr))
        nothing
    end
    return Float64(out_speed[])
end

"""
    set_fallback_coordinate_type!(params::TableParams, coord_type::TableFallbackCoordinate)

Set coordinate type for fallback results (input or snapped).
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
    get_fallback_coordinate_type(params::TableParams) -> TableFallbackCoordinate

Get coordinate type for fallback results.
"""
function get_fallback_coordinate_type(params::TableParams)
    out_coord_type = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_fallback_coordinate_type, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_coord_type, error_pointer(error_ptr))
        nothing
    end
    return TableFallbackCoordinate(out_coord_type[])
end

"""
    set_scale_factor!(params::TableParams, factor)

Set scale factor for unreachable entries.
"""
function set_scale_factor!(params::TableParams, factor::Real)
    with_error() do error_ptr
        ccall((:osrmc_table_params_set_scale_factor, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params.ptr, Cdouble(factor), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_scale_factor(params::TableParams) -> Float64

Get scale factor for unreachable entries.
"""
function get_scale_factor(params::TableParams)
    out_scale_factor = Ref{Cdouble}(0.0)
    with_error() do error_ptr
        ccall((:osrmc_table_params_get_scale_factor, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cdouble}, Ptr{Ptr{Cvoid}}), params.ptr, out_scale_factor, error_pointer(error_ptr))
        nothing
    end
    return Float64(out_scale_factor[])
end

"""
    add_coordinate!(params::TableParams, coord::Position)

Add a query coordinate `(lon, lat)`.
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

function get_coordinate_count(params::TableParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_coordinate_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_coordinate(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    out_longitude = Ref{Cdouble}(0.0)
    out_latitude = Ref{Cdouble}(0.0)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_coordinate, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cdouble}, Ref{Cdouble}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            out_longitude,
            out_latitude,
            error_pointer(error_ptr),
        )
        nothing
    end
    return Position(Float64(out_longitude[]), Float64(out_latitude[]))
end

"""
    get_coordinates(params::TableParams) -> Vector{Position}

Get all query coordinates.
"""
function get_coordinates(params::TableParams)
    out_coordinates = Vector{Position}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_coordinates[i] = get_coordinate(params, i)
    end
    return out_coordinates
end

"""
    set_hint!(params::TableParams, coordinate_index, hint)

Set precomputed hint for a coordinate to skip snapping.
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

function get_hint(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    out_hint = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_hint, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cstring}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            out_hint,
            error_pointer(error_ptr),
        )
        nothing
    end
    ptr = out_hint[]
    return ptr == C_NULL ? nothing : unsafe_string(ptr)
end

"""
    get_hints(params::TableParams) -> Vector{Union{String, Nothing}}

Get all precomputed hints.
"""
function get_hints(params::TableParams)
    out_hints = Vector{Union{String, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_hints[i] = get_hint(params, i)
    end
    return out_hints
end

"""
    set_radius!(params::TableParams, coordinate_index, radius)

Set snapping radius in meters for a coordinate.
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

function get_radius(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    out_radius = Ref{Cdouble}(0.0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_radius, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cdouble}, Ref{Cint}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            out_radius,
            out_is_set,
            error_pointer(error_ptr),
        )
        nothing
    end
    return out_is_set[] != 0 ? Float64(out_radius[]) : nothing
end

"""
    get_radii(params::TableParams) -> Vector{Union{Float64, Nothing}}

Get all snapping radii in meters (or `nothing` if not set).
"""
function get_radii(params::TableParams)
    out_radii = Vector{Union{Float64, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_radii[i] = get_radius(params, i)
    end
    return out_radii
end

"""
    set_bearing!(params::TableParams, coordinate_index, value, range)

Set bearing constraint (heading and range) for a coordinate.
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

function get_bearing(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    out_value = Ref{Cint}(0)
    out_range = Ref{Cint}(0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_bearing, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cint}, Ref{Cint}, Ref{Cint}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            out_value,
            out_range,
            out_is_set,
            error_pointer(error_ptr),
        )
        nothing
    end
    return out_is_set[] != 0 ? (Int(out_value[]), Int(out_range[])) : nothing
end

"""
    get_bearings(params::TableParams) -> Vector{Union{Tuple{Int, Int}, Nothing}}

Get all bearing constraints.
"""
function get_bearings(params::TableParams)
    out_bearings = Vector{Union{Tuple{Int, Int}, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_bearings[i] = get_bearing(params, i)
    end
    return out_bearings
end

"""
    set_approach!(params::TableParams, coordinate_index, approach)

Set road side approach constraint for a coordinate.
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

function get_approach(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    out_approach = Ref{Cint}(0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_approach, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cint}, Ref{Cint}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(coordinate_index - 1),
            out_approach,
            out_is_set,
            error_pointer(error_ptr),
        )
        nothing
    end
    return out_is_set[] != 0 ? Approach(out_approach[]) : nothing
end

"""
    get_approaches(params::TableParams) -> Vector{Union{Approach, Nothing}}

Get all approach constraints.
"""
function get_approaches(params::TableParams)
    out_approaches = Vector{Union{Approach, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_approaches[i] = get_approach(params, i)
    end
    return out_approaches
end

"""
    add_coordinate_with!(params::TableParams, coord::Position, radius, bearing, range)

Add a coordinate with radius and bearing constraints.
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

function get_coordinate_with(params::TableParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    coord = get_coordinate(params, coordinate_index)
    radius = get_radius(params, coordinate_index)
    bearing = get_bearing(params, coordinate_index)
    return (coord, radius, bearing)
end

"""
    get_coordinates_with(params::TableParams) -> Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}

Get all coordinates with their radius and bearing constraints.
"""
function get_coordinates_with(params::TableParams)
    count = get_coordinate_count(params)
    coordinates_with = Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}(undef, count)
    for i in 1:count
        coordinates_with[i] = get_coordinate_with(params, i)
    end
    return coordinates_with
end

"""
    add_exclude!(params::TableParams, profile)

Exclude traffic class (e.g. `"toll"`, `"ferry"`).
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

function get_exclude_count(params::TableParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_exclude_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_exclude(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_exclude = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_exclude, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cstring}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(index - 1),
            out_exclude,
            error_pointer(error_ptr),
        )
        nothing
    end
    ptr = out_exclude[]
    ptr == C_NULL && error("Exclude at index $index returned NULL")
    return unsafe_string(ptr)
end

"""
    get_excludes(params::TableParams) -> Vector{String}

Get all excluded traffic classes.
"""
function get_excludes(params::TableParams)
    out_excludes = Vector{String}(undef, get_exclude_count(params))
    for i in 1:get_exclude_count(params)
        out_excludes[i] = get_exclude(params, i)
    end
    return out_excludes
end

"""
    set_generate_hints!(params::TableParams, on)

Enable or disable hint generation for reuse in follow-up queries.
"""
function set_generate_hints!(params::TableParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_generate_hints(params::TableParams) -> Bool

Get whether hint generation is enabled.
"""
function get_generate_hints(params::TableParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_skip_waypoints!(params::TableParams, on)

Enable or disable omitting waypoint objects from the response.
"""
function set_skip_waypoints!(params::TableParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_skip_waypoints(params::TableParams) -> Bool

Get whether waypoint objects are omitted.
"""
function get_skip_waypoints(params::TableParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_snapping!(params::TableParams, snapping)

Set snapping strategy.
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

"""
    get_snapping(params::TableParams) -> Snapping

Get snapping strategy.
"""
function get_snapping(params::TableParams)
    out_snapping = Ref{Cint}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_params_get_snapping, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            out_snapping,
            error_pointer(error_ptr),
        )
        nothing
    end
    return Snapping(out_snapping[])
end
