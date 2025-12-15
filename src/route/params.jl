@inline function route_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_route_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    RouteParams()

Reusable parameter block for Route requests.
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

Enable or disable per-step turn-by-turn instructions.
"""
function set_steps!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_steps(params::RouteParams) -> Bool

Get whether per-step instructions are enabled.
"""
function get_steps(params::RouteParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_alternatives!(params::RouteParams, on)

Enable or disable multiple candidate routes.
"""
function set_alternatives!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_alternatives(params::RouteParams) -> Bool

Get whether multiple candidate routes are enabled.
"""
function get_alternatives(params::RouteParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_geometries!(params::RouteParams, geometries::Geometries)

Set geometry encoding format (e.g. GeoJSON, polyline6).
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
    get_geometries(params::RouteParams) -> Geometries

Get geometry encoding format.
"""
function get_geometries(params::RouteParams)
    out_geometries = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_geometries, error_pointer(error_ptr))
        nothing
    end
    return Geometries(out_geometries[])
end

"""
    set_overview!(params::RouteParams, overview::Overview)

Set geometry detail level (full, simplified, or none).
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
    get_overview(params::RouteParams) -> Overview

Get geometry detail level.
"""
function get_overview(params::RouteParams)
    out_overview = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_overview, error_pointer(error_ptr))
        nothing
    end
    return Overview(out_overview[])
end

"""
    set_continue_straight!(params::RouteParams, on)

Enable or disable continuing straight at roundabouts.
"""
function set_continue_straight!(params::RouteParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_continue_straight(params::RouteParams) -> Union{Bool, Nothing}

Get whether continuing straight at roundabouts is enabled (or `nothing` if not set).
"""
function get_continue_straight(params::RouteParams)
    out_on = Ref{Cint}(0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, out_is_set, error_pointer(error_ptr))
        nothing
    end
    return out_is_set[] != 0 ? (out_on[] != 0) : nothing
end

"""
    set_number_of_alternatives!(params::RouteParams, count)

Set maximum number of alternate routes to compute.
"""
function set_number_of_alternatives!(params::RouteParams, count::Integer)
    with_error() do error_ptr
        ccall((:osrmc_route_params_set_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(count), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_number_of_alternatives(params::RouteParams) -> Int

Get maximum number of alternate routes to compute.
"""
function get_number_of_alternatives(params::RouteParams)
    out_count = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

"""
    set_annotations!(params::RouteParams, annotations::Annotations)

Set per-edge metadata flags (speed, duration, etc.).
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
    get_annotations(params::RouteParams) -> Annotations

Get annotation flags.
"""
function get_annotations(params::RouteParams)
    out_annotations = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_annotations, error_pointer(error_ptr))
        nothing
    end
    return Annotations(out_annotations[])
end

"""
    add_waypoint!(params::RouteParams, index)

Mark a coordinate as a waypoint.
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

Clear all waypoint selections.
"""
function clear_waypoints!(params::RouteParams)
    ccall((:osrmc_route_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params.ptr)
    return nothing
end


function get_waypoint_count(params::RouteParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_route_params_get_waypoint_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end


function get_waypoint(params::RouteParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_index = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_route_params_get_waypoint, libosrmc),
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
    get_waypoints(params::RouteParams) -> Vector{Int}

Get all waypoint coordinate indices.
"""
function get_waypoints(params::RouteParams)
    out_waypoints = Vector{Int}(undef, get_waypoint_count(params))
    for i in 1:get_waypoint_count(params)
        out_waypoints[i] = get_waypoint(params, i)
    end
    return out_waypoints
end

"""
    add_coordinate!(params::RouteParams, coord::Position)

Add a query coordinate `(lon, lat)`.
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

function get_coordinate_count(params::RouteParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_coordinate_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_coordinate(params::RouteParams, coordinate_index::Integer)
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
    get_coordinates(params::RouteParams) -> Vector{Position}

Get all query coordinates.
"""
function get_coordinates(params::RouteParams)
    out_coordinates = Vector{Position}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_coordinates[i] = get_coordinate(params, i)
    end
    return out_coordinates
end

"""
    set_hint!(params::RouteParams, coordinate_index, hint)

Set precomputed hint for a coordinate to skip snapping.
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

function get_hint(params::RouteParams, coordinate_index::Integer)
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
    get_hints(params::RouteParams) -> Vector{Union{String, Nothing}}

Get all precomputed hints.
"""
function get_hints(params::RouteParams)
    out_hints = Vector{Union{String, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_hints[i] = get_hint(params, i)
    end
    return out_hints
end

"""
    set_radius!(params::RouteParams, coordinate_index, radius)

Set search radius in meters for a coordinate.
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

function get_radius(params::RouteParams, coordinate_index::Integer)
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
    get_radii(params::RouteParams) -> Vector{Union{Float64, Nothing}}

Get all search radii in meters (or `nothing` if not set).
"""
function get_radii(params::RouteParams)
    out_radii = Vector{Union{Float64, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_radii[i] = get_radius(params, i)
    end
    return out_radii
end

"""
    set_bearing!(params::RouteParams, coordinate_index, value, range)

Set bearing constraint (heading and range) for a coordinate.
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

function get_bearing(params::RouteParams, coordinate_index::Integer)
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
    get_bearings(params::RouteParams) -> Vector{Union{Tuple{Int, Int}, Nothing}}

Get all bearing constraints.
"""
function get_bearings(params::RouteParams)
    out_bearings = Vector{Union{Tuple{Int, Int}, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_bearings[i] = get_bearing(params, i)
    end
    return out_bearings
end

"""
    set_approach!(params::RouteParams, coordinate_index, approach::Approach)

Set road side approach constraint for a coordinate.
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

function get_approach(params::RouteParams, coordinate_index::Integer)
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
    get_approaches(params::RouteParams) -> Vector{Union{Approach, Nothing}}

Get all approach constraints.
"""
function get_approaches(params::RouteParams)
    out_approaches = Vector{Union{Approach, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_approaches[i] = get_approach(params, i)
    end
    return out_approaches
end

"""
    add_coordinate_with!(params::RouteParams, coord::Position, radius, bearing, range)

Add a coordinate with radius and bearing constraints.
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

function get_coordinate_with(params::RouteParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    coord = get_coordinate(params, coordinate_index)
    radius = get_radius(params, coordinate_index)
    bearing = get_bearing(params, coordinate_index)
    return (coord, radius, bearing)
end

"""
    get_coordinates_with(params::RouteParams) -> Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}

Get all coordinates with their radius and bearing constraints.
"""
function get_coordinates_with(params::RouteParams)
    count = get_coordinate_count(params)
    coordinates_with = Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}(undef, count)
    for i in 1:count
        coordinates_with[i] = get_coordinate_with(params, i)
    end
    return coordinates_with
end

"""
    add_exclude!(params::RouteParams, profile)

Exclude traffic class (e.g. `"toll"`, `"ferry"`).
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

function get_exclude_count(params::RouteParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_exclude_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_exclude(params::RouteParams, index::Integer)
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
    get_excludes(params::RouteParams) -> Vector{String}

Get all excluded traffic classes.
"""
function get_excludes(params::RouteParams)
    out_excludes = Vector{String}(undef, get_exclude_count(params))
    for i in 1:get_exclude_count(params)
        out_excludes[i] = get_exclude(params, i)
    end
    return out_excludes
end

"""
    set_generate_hints!(params::RouteParams, on)

Enable or disable hint generation for reuse in follow-up queries.
"""
function set_generate_hints!(params::RouteParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    get_generate_hints(params::RouteParams) -> Bool

Get whether hint generation is enabled.
"""
function get_generate_hints(params::RouteParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_skip_waypoints!(params::RouteParams, on)

Enable or disable omitting waypoint objects from the response.
"""
function set_skip_waypoints!(params::RouteParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    get_skip_waypoints(params::RouteParams) -> Bool

Get whether waypoint objects are omitted.
"""
function get_skip_waypoints(params::RouteParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_snapping!(params::RouteParams, snapping::Snapping)

Set snapping strategy.
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

"""
    get_snapping(params::RouteParams) -> Snapping

Get snapping strategy.
"""
function get_snapping(params::RouteParams)
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
