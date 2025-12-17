@inline function trip_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_trip_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    TripParams()

Reusable parameter block for Trip requests.
"""
mutable struct TripParams
    ptr::Ptr{Cvoid}

    function TripParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_trip_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        finalize(params, trip_params_destruct)
        return params
    end
end

"""
    set_steps!(params::TripParams, on)

Enable or disable per-step turn-by-turn instructions.
"""
function set_steps!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_steps(params::TripParams) -> Bool

Get whether per-step instructions are enabled.
"""
function get_steps(params::TripParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_alternatives!(params::TripParams, on)

Enable or disable multiple candidate routes.
"""
function set_alternatives!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_alternatives(params::TripParams) -> Bool

Get whether multiple candidate routes are enabled.
"""
function get_alternatives(params::TripParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_geometries!(params::TripParams, geometries)

Set geometry encoding format (e.g. GeoJSON, polyline6).
"""
function set_geometries!(params::TripParams, geometries::Geometries)
    code = Cint(geometries)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_geometries(params::TripParams) -> Geometries

Get geometry encoding format.
"""
function get_geometries(params::TripParams)
    out_geometries = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_geometries, error_pointer(error_ptr))
        nothing
    end
    return Geometries(out_geometries[])
end

"""
    set_overview!(params::TripParams, overview)

Set geometry detail level (full, simplified, or none).
"""
function set_overview!(params::TripParams, overview::Overview)
    code = Cint(overview)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_overview(params::TripParams) -> Overview

Get geometry detail level.
"""
function get_overview(params::TripParams)
    out_overview = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_overview, error_pointer(error_ptr))
        nothing
    end
    return Overview(out_overview[])
end

"""
    set_continue_straight!(params::TripParams, on)

Enable or disable continuing straight at roundabouts.
"""
function set_continue_straight!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_continue_straight(params::TripParams) -> Union{Bool, Nothing}

Get whether continuing straight at roundabouts is enabled (or `nothing` if not set).
"""
function get_continue_straight(params::TripParams)
    out_on = Ref{Cint}(0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, out_is_set, error_pointer(error_ptr))
        nothing
    end
    return out_is_set[] != 0 ? (out_on[] != 0) : nothing
end

"""
    set_number_of_alternatives!(params::TripParams, count)

Set maximum number of alternate routes to compute.
"""
function set_number_of_alternatives!(params::TripParams, count::Integer)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(count), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_number_of_alternatives(params::TripParams) -> Int

Get maximum number of alternate routes to compute.
"""
function get_number_of_alternatives(params::TripParams)
    out_count = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

"""
    set_annotations!(params::TripParams, annotations)

Set per-edge metadata flags (speed, duration, etc.).
"""
function set_annotations!(params::TripParams, annotations::Annotations)
    code = Cint(annotations)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_annotations(params::TripParams) -> Annotations

Get annotation flags.
"""
function get_annotations(params::TripParams)
    out_annotations = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_annotations, error_pointer(error_ptr))
        nothing
    end
    return Annotations(out_annotations[])
end

"""
    set_roundtrip!(params::TripParams, on)

Enable or disable returning to the starting point.
"""
function set_roundtrip!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_roundtrip, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_roundtrip(params::TripParams) -> Bool

Get whether returning to the starting point is enabled.
"""
function get_roundtrip(params::TripParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_roundtrip, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_source!(params::TripParams, source)

Set trip start behavior (any or first).
"""
function set_source!(params::TripParams, source::TripSource)
    code = Cint(source)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_source, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_source(params::TripParams) -> TripSource

Get trip start behavior.
"""
function get_source(params::TripParams)
    out_source = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_source, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_source, error_pointer(error_ptr))
        nothing
    end
    return TripSource(out_source[])
end

"""
    set_destination!(params::TripParams, destination)

Set trip endpoint behavior (any or last).
"""
function set_destination!(params::TripParams, destination::TripDestination)
    code = Cint(destination)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_set_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_destination(params::TripParams) -> TripDestination

Get trip endpoint behavior.
"""
function get_destination(params::TripParams)
    out_destination = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_destination, error_pointer(error_ptr))
        nothing
    end
    return TripDestination(out_destination[])
end

"""
    clear_waypoints!(params::TripParams)

Clear all waypoint selections.
"""
function clear_waypoints!(params::TripParams)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), params.ptr, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

function get_waypoint_count(params::TripParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_trip_params_get_waypoint_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_waypoint(params::TripParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_index = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_trip_params_get_waypoint, libosrmc),
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
    add_waypoint!(params::TripParams, index)

Mark a coordinate as a waypoint.
"""
function add_waypoint!(params::TripParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do error_ptr
        ccall((:osrmc_trip_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params.ptr, Csize_t(index - 1), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    add_coordinate!(params::TripParams, coord::Position)

Add a query coordinate `(lon, lat)`.
"""
function add_coordinate!(params::TripParams, coord::Position)
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

function get_coordinate_count(params::TripParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_coordinate_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_coordinate(params::TripParams, coordinate_index::Integer)
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
    get_coordinates(params::TripParams) -> Vector{Position}

Get all query coordinates.
"""
function get_coordinates(params::TripParams)
    out_coordinates = Vector{Position}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_coordinates[i] = get_coordinate(params, i)
    end
    return out_coordinates
end

"""
    set_hint!(params::TripParams, coordinate_index, hint)

Set precomputed hint for a coordinate to skip snapping.
"""
function set_hint!(params::TripParams, coordinate_index::Integer, hint::AbstractString)
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

function get_hint(params::TripParams, coordinate_index::Integer)
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
    get_hints(params::TripParams) -> Vector{Union{String, Nothing}}

Get all precomputed hints.
"""
function get_hints(params::TripParams)
    out_hints = Vector{Union{String, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_hints[i] = get_hint(params, i)
    end
    return out_hints
end

"""
    set_radius!(params::TripParams, coordinate_index, radius)

Set snapping radius in meters for a coordinate.
"""
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

function get_radius(params::TripParams, coordinate_index::Integer)
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
    get_radii(params::TripParams) -> Vector{Union{Float64, Nothing}}

Get all snapping radii in meters (or `nothing` if not set).
"""
function get_radii(params::TripParams)
    out_radii = Vector{Union{Float64, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_radii[i] = get_radius(params, i)
    end
    return out_radii
end

"""
    set_bearing!(params::TripParams, coordinate_index, value, range)

Set bearing constraint (heading and range) for a coordinate.
"""
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

function get_bearing(params::TripParams, coordinate_index::Integer)
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
    get_bearings(params::TripParams) -> Vector{Union{Tuple{Int, Int}, Nothing}}

Get all bearing constraints.
"""
function get_bearings(params::TripParams)
    out_bearings = Vector{Union{Tuple{Int, Int}, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_bearings[i] = get_bearing(params, i)
    end
    return out_bearings
end

"""
    set_approach!(params::TripParams, coordinate_index, approach)

Set road side approach constraint for a coordinate.
"""
function set_approach!(params::TripParams, coordinate_index::Integer, approach::Approach)
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

function get_approach(params::TripParams, coordinate_index::Integer)
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
    get_approaches(params::TripParams) -> Vector{Union{Approach, Nothing}}

Get all approach constraints.
"""
function get_approaches(params::TripParams)
    out_approaches = Vector{Union{Approach, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_approaches[i] = get_approach(params, i)
    end
    return out_approaches
end


"""
    add_coordinate_with!(params::TripParams, coord::Position, radius, bearing, range)

Add a coordinate with radius and bearing constraints.
"""
function add_coordinate_with!(params::TripParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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

function get_coordinate_with(params::TripParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    coord = get_coordinate(params, coordinate_index)
    radius = get_radius(params, coordinate_index)
    bearing = get_bearing(params, coordinate_index)
    return (coord, radius, bearing)
end

"""
    get_coordinates_with(params::TripParams) -> Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}

Get all coordinates with hints for the Trip request.
"""
function get_coordinates_with(params::TripParams)
    count = get_coordinate_count(params)
    coordinates_with = Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}(undef, count)
    for i in 1:count
        coordinates_with[i] = get_coordinate_with(params, i)
    end
    return coordinates_with
end

"""
    add_exclude!(params::TripParams, profile)

Exclude traffic class (e.g. `"toll"`, `"ferry"`).
"""
function add_exclude!(params::TripParams, profile::AbstractString)
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

function get_exclude_count(params::TripParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_exclude_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_exclude(params::TripParams, index::Integer)
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
    get_excludes(params::TripParams) -> Vector{String}

Get all excluded traffic classes.
"""
function get_excludes(params::TripParams)
    out_excludes = Vector{String}(undef, get_exclude_count(params))
    for i in 1:get_exclude_count(params)
        out_excludes[i] = get_exclude(params, i)
    end
    return out_excludes
end

"""
    set_generate_hints!(params::TripParams, on)

Enable or disable hint generation for reuse in follow-up queries.
"""
function set_generate_hints!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_generate_hints(params::TripParams) -> Bool

Get whether hint generation is enabled.
"""
function get_generate_hints(params::TripParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_skip_waypoints!(params::TripParams, on)

Enable or disable omitting waypoint objects from the response.
"""
function set_skip_waypoints!(params::TripParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_skip_waypoints(params::TripParams) -> Bool

Get whether waypoint objects are omitted.
"""
function get_skip_waypoints(params::TripParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_snapping!(params::TripParams, snapping)

Set snapping strategy.
"""
function set_snapping!(params::TripParams, snapping::Snapping)
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
    get_snapping(params::TripParams) -> Snapping

Get snapping strategy.
"""
function get_snapping(params::TripParams)
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

"""
    get_waypoints(params::TripParams) -> Vector{Int}

Get all waypoint coordinate indices.
"""
function get_waypoints(params::TripParams)
    out_waypoints = Vector{Int}(undef, get_waypoint_count(params))
    for i in 1:get_waypoint_count(params)
        out_waypoints[i] = get_waypoint(params, i)
    end
    return out_waypoints
end
