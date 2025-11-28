"""
    RouteResponse

Owns the libosrmc route response pointer and cleans it up automatically when
the Julia object is collected.
"""
function _route_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_route_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct RouteResponse
    ptr::Ptr{Cvoid}

    function RouteResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct RouteResponse from NULL pointer")
        response = new(ptr)
        Utils.finalize(response, _route_response_destruct)
        return response
    end
end

"""
    as_json(response::RouteResponse) -> String

Provide the canonical OSRM JSON payload for logging or interoperability with
existing tooling.
"""
function as_json(response::RouteResponse)
    blob = with_error() do err
        ccall((:osrmc_route_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return Utils.as_string(blob)
end

"""
    distance(response::RouteResponse) -> Float64

Return OSRM's distance computation so callers do not have to integrate the
polyline themselves.
"""
function distance(response::RouteResponse)
    return with_error() do err
        ccall((:osrmc_route_response_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
end

"""
    duration(response::RouteResponse) -> Float64

Read OSRM's travel time estimate directly, keeping the Julia client aligned
with server heuristics.
"""
function duration(response::RouteResponse)
    return with_error() do err
        ccall((:osrmc_route_response_duration, libosrmc), Cdouble, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
end

"""
    alternative_count(response) -> Int

Expose how many alternate routes OSRM generated so UI layers can decide whether
to show a picker.
"""
alternative_count(response::RouteResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_route_response_alternative_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    distance_at(response, route_index) -> Float64

Fetch the distance for a specific alternative instead of assuming the primary
route is always desired.
"""
function distance_at(response::RouteResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_distance_at, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

"""
    duration_at(response, route_index) -> Float64

Per-alternative durations help heuristics compare ETA differences before
downloading geometries.
"""
function duration_at(response::RouteResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_duration_at, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

"""
    geometry_polyline(response, route_index=1) -> String

Return the encoded polyline OSRM generated so clients can render it without
reconstructing geometries.
"""
function geometry_polyline(response::RouteResponse, route_index::Integer = 1)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    cstr = with_error() do err
        ccall((:osrmc_route_response_geometry_polyline, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

geometry_coordinate_count(response::RouteResponse, route_index::Integer = 1) =
    Int(
    with_error() do err
        @assert route_index >= 1 "Julia uses 1-based indexing"
        ccall((:osrmc_route_response_geometry_coordinate_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end,
)

function geometry_coordinate_latitude(response::RouteResponse, route_index::Integer, coord_index::Integer)
    @assert route_index >= 1 && coord_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_geometry_coordinate_latitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(coord_index - 1), error_pointer(err))
    end
end

function geometry_coordinate_longitude(response::RouteResponse, route_index::Integer, coord_index::Integer)
    @assert route_index >= 1 && coord_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_geometry_coordinate_longitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(coord_index - 1), error_pointer(err))
    end
end

waypoint_count(response::RouteResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_route_response_waypoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

function waypoint_latitude(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_waypoint_latitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function waypoint_longitude(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_waypoint_longitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function waypoint_name(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    cstr = with_error() do err
        ccall((:osrmc_route_response_waypoint_name, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

function leg_count(response::RouteResponse, route_index::Integer = 1)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    return Int(
        with_error() do err
            ccall((:osrmc_route_response_leg_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
        end,
    )
end

function step_count(response::RouteResponse, route_index::Integer, leg_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 "Julia uses 1-based indexing"
    return Int(
        with_error() do err
            ccall((:osrmc_route_response_step_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), error_pointer(err))
        end,
    )
end

function step_distance(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_step_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
end

function step_duration(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_route_response_step_duration, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
end

function step_instruction(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    cstr = with_error() do err
        ccall((:osrmc_route_response_step_instruction, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end
