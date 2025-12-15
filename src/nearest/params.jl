@inline function nearest_params_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_nearest_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

"""
    NearestParams()

Reusable parameter block for Nearest requests.
"""
mutable struct NearestParams
    ptr::Ptr{Cvoid}

    function NearestParams()
        ptr = with_error() do error_ptr
            ccall((:osrmc_nearest_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error_pointer(error_ptr))
        end
        params = new(ptr)
        finalize(params, nearest_params_destruct)
        return params
    end
end

"""
    set_number_of_results!(params::NearestParams, n)

Set maximum number of candidates to return.
"""
function set_number_of_results!(params::NearestParams, n::Integer)
    with_error() do error_ptr
        ccall((:osrmc_nearest_params_set_number_of_results, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params.ptr, Cuint(n), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_number_of_results(params::NearestParams) -> Int

Get maximum number of candidates to return.
"""
function get_number_of_results(params::NearestParams)
    out_n = Ref{Cuint}(0)
    with_error() do error_ptr
        ccall((:osrmc_nearest_params_get_number_of_results, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cuint}, Ptr{Ptr{Cvoid}}), params.ptr, out_n, error_pointer(error_ptr))
        nothing
    end
    return Int(out_n[])
end

"""
    add_coordinate!(params::NearestParams, coord::Position)

Add a query coordinate `(lon, lat)`.
"""
function add_coordinate!(params::NearestParams, coord::Position)
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

function get_coordinate_count(params::NearestParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_coordinate_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_coordinate(params::NearestParams, coordinate_index::Integer)
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
    get_coordinates(params::NearestParams) -> Vector{Position}

Get all query coordinates.
"""
function get_coordinates(params::NearestParams)
    out_coordinates = Vector{Position}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_coordinates[i] = get_coordinate(params, i)
    end
    return out_coordinates
end

"""
    set_hint!(params::NearestParams, coordinate_index, hint)

Set precomputed hint for a coordinate to skip snapping.
"""
function set_hint!(params::NearestParams, coordinate_index::Integer, hint::AbstractString)
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

function get_hint(params::NearestParams, coordinate_index::Integer)
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
    get_hints(params::NearestParams) -> Vector{Union{String, Nothing}}

Get all precomputed hints.
"""
function get_hints(params::NearestParams)
    out_hints = Vector{Union{String, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_hints[i] = get_hint(params, i)
    end
    return out_hints
end

"""
    set_radius!(params::NearestParams, coordinate_index, radius)

Set snapping radius in meters for a coordinate.
"""
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

function get_radius(params::NearestParams, coordinate_index::Integer)
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
    get_radii(params::NearestParams) -> Vector{Union{Float64, Nothing}}

Get all snapping radii in meters (or `nothing` if not set).
"""
function get_radii(params::NearestParams)
    out_radii = Vector{Union{Float64, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_radii[i] = get_radius(params, i)
    end
    return out_radii
end

"""
    set_bearing!(params::NearestParams, coordinate_index, value, range)

Set bearing constraint (heading and range) for a coordinate.
"""
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

function get_bearing(params::NearestParams, coordinate_index::Integer)
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
    get_bearings(params::NearestParams) -> Vector{Union{Tuple{Int, Int}, Nothing}}

Get all bearing constraints.
"""
function get_bearings(params::NearestParams)
    out_bearings = Vector{Union{Tuple{Int, Int}, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_bearings[i] = get_bearing(params, i)
    end
    return out_bearings
end


"""
    set_approach!(params::NearestParams, coordinate_index, approach)

Set road side approach constraint for a coordinate.
"""
function set_approach!(params::NearestParams, coordinate_index::Integer, approach::Approach)
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

function get_approach(params::NearestParams, coordinate_index::Integer)
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
    get_approaches(params::NearestParams) -> Vector{Union{Approach, Nothing}}

Get all approach constraints.
"""
function get_approaches(params::NearestParams)
    out_approaches = Vector{Union{Approach, Nothing}}(undef, get_coordinate_count(params))
    for i in 1:get_coordinate_count(params)
        out_approaches[i] = get_approach(params, i)
    end
    return out_approaches
end

"""
    add_coordinate_with!(params::NearestParams, coord::Position, radius, bearing, range)

Add a coordinate with radius and bearing constraints.
"""
function add_coordinate_with!(params::NearestParams, coord::Position, radius::Real, bearing::Integer, range::Integer)
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

function get_coordinate_with(params::NearestParams, coordinate_index::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    coord = get_coordinate(params, coordinate_index)
    radius = get_radius(params, coordinate_index)
    bearing = get_bearing(params, coordinate_index)
    return (coord, radius, bearing)
end

"""
    get_coordinates_with(params::NearestParams) -> Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}

Get all coordinates with their radius and bearing constraints.
"""
function get_coordinates_with(params::NearestParams)
    count = get_coordinate_count(params)
    coordinates_with = Vector{Tuple{Position, Union{Float64, Nothing}, Union{Tuple{Int, Int}, Nothing}}}(undef, count)
    for i in 1:count
        coordinates_with[i] = get_coordinate_with(params, i)
    end
    return coordinates_with
end

"""
    add_exclude!(params::NearestParams, profile)

Exclude traffic class (e.g. `"toll"`, `"ferry"`).
"""
function add_exclude!(params::NearestParams, profile::AbstractString)
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

function get_exclude_count(params::NearestParams)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_exclude_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), params.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end

function get_exclude(params::NearestParams, index::Integer)
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
    get_excludes(params::NearestParams) -> Vector{String}

Get all excluded traffic classes.
"""
function get_excludes(params::NearestParams)
    out_excludes = Vector{String}(undef, get_exclude_count(params))
    for i in 1:get_exclude_count(params)
        out_excludes[i] = get_exclude(params, i)
    end
    return out_excludes
end

"""
    set_generate_hints!(params::NearestParams, on)

Enable or disable hint generation for reuse in follow-up queries.
"""
function set_generate_hints!(params::NearestParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_generate_hints(params::NearestParams) -> Bool

Get whether hint generation is enabled.
"""
function get_generate_hints(params::NearestParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_skip_waypoints!(params::NearestParams, on)

Enable or disable omitting waypoint objects from the response.
"""
function set_skip_waypoints!(params::NearestParams, on::Bool)
    with_error() do error_ptr
        ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params.ptr, Cint(on), error_pointer(error_ptr))
        nothing
    end
    return nothing
end

"""
    get_skip_waypoints(params::NearestParams) -> Bool

Get whether waypoint objects are omitted.
"""
function get_skip_waypoints(params::NearestParams)
    out_on = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_params_get_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), params.ptr, out_on, error_pointer(error_ptr))
        nothing
    end
    return out_on[] != 0
end

"""
    set_snapping!(params::NearestParams, snapping)

Set snapping strategy.
"""
function set_snapping!(params::NearestParams, snapping::Snapping)
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
    get_snapping(params::NearestParams) -> Snapping

Get snapping strategy.
"""
function get_snapping(params::NearestParams)
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
