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
        finalize(params, match_params_destruct)
        return params
    end
end

"""
    set_steps!(params::MatchParams, on)

Mirrors the Route behavior so callers can request per-step guidance while
running map-matching.
"""
function set_steps!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_steps(params::MatchParams) -> Bool

Get whether per-step instructions are requested.
"""
function get_steps(params::MatchParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_alternatives!(params::MatchParams, on)

Allows the matcher to keep alternate routes which helps downstream quality
checks decide when to fall back.
"""
function set_alternatives!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_alternatives(params::MatchParams) -> Bool

Get whether alternate routes are requested.
"""
function get_alternatives(params::MatchParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_geometries!(params::MatchParams, geometries)
"""
function set_geometries!(params::MatchParams, geometries::Geometries)
    code = Cint(geometries)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_geometries(params::MatchParams) -> Geometries

Get the geometry encoding format configured for matches.
"""
function get_geometries(params::MatchParams)
    out_geometries = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_geometries, error_pointer(error_ptr))
        nothing
    end
    return Geometries(out_geometries[])
end

"""
    set_overview!(params::MatchParams, overview)
"""
function set_overview!(params::MatchParams, overview::Overview)
    code = Cint(overview)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_overview(params::MatchParams) -> Overview

Get how much geometry detail is configured for matches.
"""
function get_overview(params::MatchParams)
    out_overview = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_overview, error_pointer(error_ptr))
        nothing
    end
    return Overview(out_overview[])
end

"""
    set_continue_straight!(params::MatchParams, on)
"""
function set_continue_straight!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_continue_straight(params::MatchParams) -> Union{Bool, Nothing}

Get whether vehicles should continue straight at roundabouts (or `nothing` if not set).
"""
function get_continue_straight(params::MatchParams)
    out_on = Ref{Cint}(0)
    out_is_set = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, out_is_set, error_pointer(error_ptr))
        nothing
    end
    return out_is_set[] != 0 ? (out_on[] != 0) : nothing
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
    get_number_of_alternatives(params::MatchParams) -> Int

Get the maximum number of alternate routes to compute.
"""
function get_number_of_alternatives(params::MatchParams)
    out_count = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

"""
    set_annotations!(params::MatchParams, annotations)
"""
function set_annotations!(params::MatchParams, annotations::Annotations)
    code = Cint(annotations)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_annotations(params::MatchParams) -> Annotations

Get the annotation flags configured for match metadata.
"""
function get_annotations(params::MatchParams)
    out_annotations = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_annotations, error_pointer(error_ptr))
        nothing
    end
    return Annotations(out_annotations[])
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

function get_waypoint_count(params::MatchParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_waypoint_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_waypoint(params::MatchParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_index = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_match_params_get_waypoint, libosrmc),
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

function get_timestamp_count(params::MatchParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_timestamp_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_timestamp(params::MatchParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    out_timestamp = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall(
            (:osrmc_match_params_get_timestamp, libosrmc),
            Cvoid,
            (Ptr{Cvoid}, Csize_t, Ref{Cuint}, Ptr{Ptr{Cvoid}}),
            params.ptr,
            Csize_t(index - 1),
            out_timestamp,
            error_pointer(error_ptr),
        )
        nothing
    end
    return Int(out_timestamp[])
end

"""
    get_timestamps(params::MatchParams) -> Vector{Int}

Get all timestamps added to the Match request.
"""
function get_timestamps(params::MatchParams)
    out_timestamps = Vector{Int}(undef, get_timestamp_count(params))
    for i in 1:get_timestamp_count(params)
        out_timestamps[i] = get_timestamp(params, i)
    end
    return out_timestamps
end

"""
    set_gaps!(params::MatchParams, gaps)

Tells OSRM how to treat missing samples (split vs. ignore), letting analytics
pipelines encode their tolerance for GPS outages.
"""
function set_gaps!(params::MatchParams, gaps::MatchGaps)
    code = Cint(gaps)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_gaps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_gaps(params::MatchParams) -> MatchGaps

Get how missing samples are treated (split vs. ignore).
"""
function get_gaps(params::MatchParams)
    out_gaps = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_gaps, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_gaps, error_pointer(error_ptr))
        nothing
    end
    return MatchGaps(out_gaps[])
end

"""
    set_tidy!(params::MatchParams, on)

Requests OSRM to drop redundant tracepoints, which reduces downstream storage
when high-frequency logs are matched.
"""
function set_tidy!(params::MatchParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_match_params_set_tidy, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_tidy(params::MatchParams) -> Bool

Get whether redundant tracepoints are dropped.
"""
function get_tidy(params::MatchParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_match_params_get_tidy, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

function add_coordinate!(params::MatchParams, coord::Position)
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

function get_coordinate_count(params::MatchParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_coordinate_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_coordinate(params::MatchParams, coordinate_index::Integer)
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
    get_coordinates(params::MatchParams) -> Vector{Position}

Get all coordinates added to the Match request.
"""
function get_coordinates(params::MatchParams)
    out_coordinates = Vector{Position}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_coordinates[i] = get_coordinate(params, i)
    end
    return out_coordinates
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
            Base.unsafe_convert(Cstring, Base.cconvert(Cstring, hint)),
            error_pointer(error_ptr),
        )
        nothing
    end
    return nothing
end

function get_hint(params::MatchParams, coordinate_index::Integer)
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
    get_hints(params::MatchParams) -> Vector{Union{String, Nothing}}

Get all precomputed hints for the coordinates added to the Match request.
"""
function get_hints(params::MatchParams)
    out_hints = Vector{Union{String, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_hints[i] = get_hint(params, i)
    end
    return out_hints
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

function get_radius(params::MatchParams, coordinate_index::Integer)
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
    get_radii(params::MatchParams) -> Vector{Union{Float64, Nothing}}

Get all per-coordinate snapping radii in meters (or `nothing` if not set).
"""
function get_radii(params::MatchParams)
    out_radii = Vector{Union{Float64, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_radii[i] = get_radius(params, i)
    end
    return out_radii
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

function get_bearing(params::MatchParams, coordinate_index::Integer)
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
    get_bearings(params::MatchParams) -> Vector{Union{Tuple{Int, Int}, Nothing}}

Get all bearing constraints for the coordinates added to the Match request.
"""
function get_bearings(params::MatchParams)
    out_bearings = Vector{Union{Tuple{Int, Int}, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_bearings[i] = get_bearing(params, i)
    end
    return out_bearings
end

function set_approach!(params::MatchParams, coordinate_index::Integer, approach::Approach)
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

function get_approach(params::MatchParams, coordinate_index::Integer)
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
    get_approaches(params::MatchParams) -> Vector{Union{Approach, Nothing}}

Get all approach constraints for the coordinates added to the Match request.
"""
function get_approaches(params::MatchParams)
    out_approaches = Vector{Union{Approach, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_approaches[i] = get_approach(params, i)
    end
    return out_approaches
end

function add_coordinate_with!(params::MatchParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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

function get_coordinate_with(params::MatchParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    coord = get_coordinate(params, coordinate_index)
    radius = get_radius(params, coordinate_index)
    bearing = get_bearing(params, coordinate_index)
    return (coord, radius, bearing)
end

"""
    get_coordinates_with(params::MatchParams) -> Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}

Get all coordinates with hints for the Match request.
"""
function get_coordinates_with(params::MatchParams)
    count = get_coordinate_count(params)
    coordinates_with = Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}(undef, count)
    for i in 1:count
        coordinates_with[i] = get_coordinate_with(params, i)
    end
    return coordinates_with
end

function add_exclude!(params::MatchParams, profile::AbstractString)
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

function get_exclude_count(params::MatchParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_exclude_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_exclude(params::MatchParams, index::Integer)
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
    get_excludes(params::MatchParams) -> Vector{String}

Get all excluded traffic classes for the Match request.
"""
function get_excludes(params::MatchParams)
    out_excludes = Vector{String}(undef, get_exclude_count(params))
    for i in 1:get_exclude_count(params)
        out_excludes[i] = get_exclude(params, i)
    end
    return out_excludes
end

function set_generate_hints!(params::MatchParams, on::Bool)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    get_generate_hints(params::MatchParams) -> Bool

Get whether hints are generated for Match results.
"""
function get_generate_hints(params::MatchParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

function set_skip_waypoints!(params::MatchParams, on::Bool)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params.ptr, Cint(on))
    return nothing
end

"""
    get_skip_waypoints(params::MatchParams) -> Bool

Get whether waypoint objects are omitted from the response.
"""
function get_skip_waypoints(params::MatchParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

function set_snapping!(params::MatchParams, snapping::Snapping)
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
    get_snapping(params::MatchParams) -> Snapping

Get the snapping strategy configured for Match requests.
"""
function get_snapping(params::MatchParams)
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
    get_waypoints(params::MatchParams) -> Vector{Int}

Get all waypoint coordinate indices configured for the match.
"""
function get_waypoints(params::MatchParams)
    out_waypoints = Vector{Int}(undef, get_waypoint_count(params))
    for i in 1:get_waypoint_count(params)
        out_waypoints[i] = get_waypoint(params, i)
    end
    return out_waypoints
end
