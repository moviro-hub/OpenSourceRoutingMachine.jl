"""
Typed wrapper around OSRM's Route service so we can reuse the native engine
without spinning up osrm-routed.
"""
module Route

using ..CWrapper
using ..Error: with_error, error_pointer
using ..Utils: blob_to_string, _finalize_response!
import ..Config: OSRM
import ..Params: RouteParams

"""
    RouteResponse

Owns the libosrmc route response pointer and cleans it up automatically when
the Julia object is collected.
"""
mutable struct RouteResponse
    ptr::Ptr{Cvoid}

    function RouteResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct RouteResponse from NULL pointer")
        response = new(ptr)
        _finalize_response!(response, CWrapper.osrmc_route_response_destruct)
        return response
    end
end

"""
    distance(response::RouteResponse) -> Float32

Return OSRM's distance computation so callers do not have to integrate the
polyline themselves.
"""
distance(response::RouteResponse) =
    with_error() do err
        CWrapper.osrmc_route_response_distance(response.ptr, error_pointer(err))
    end

"""
    duration(response::RouteResponse) -> Float32

Read OSRM's travel time estimate directly, keeping the Julia client aligned
with server heuristics.
"""
duration(response::RouteResponse) =
    with_error() do err
        CWrapper.osrmc_route_response_duration(response.ptr, error_pointer(err))
    end

"""
    alternative_count(response) -> Int

Expose how many alternate routes OSRM generated so UI layers can decide whether
to show a picker.
"""
alternative_count(response::RouteResponse) =
    Int(with_error() do err
        CWrapper.osrmc_route_response_alternative_count(response.ptr, error_pointer(err))
    end)

"""
    distance_at(response, route_index) -> Float32

Fetch the distance for a specific alternative instead of assuming the primary
route is always desired.
"""
function distance_at(response::RouteResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_distance_at(response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

"""
    duration_at(response, route_index) -> Float32

Per-alternative durations help heuristics compare ETA differences before
downloading geometries.
"""
function duration_at(response::RouteResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_duration_at(response.ptr, Cuint(route_index - 1), error_pointer(err))
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
        CWrapper.osrmc_route_response_geometry_polyline(response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

geometry_coordinate_count(response::RouteResponse, route_index::Integer = 1) =
    Int(with_error() do err
        @assert route_index >= 1 "Julia uses 1-based indexing"
        CWrapper.osrmc_route_response_geometry_coordinate_count(response.ptr, Cuint(route_index - 1), error_pointer(err))
    end)

function geometry_coordinate_latitude(response::RouteResponse, route_index::Integer, coord_index::Integer)
    @assert route_index >= 1 && coord_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_geometry_coordinate_latitude(response.ptr, Cuint(route_index - 1), Cuint(coord_index - 1), error_pointer(err))
    end
end

function geometry_coordinate_longitude(response::RouteResponse, route_index::Integer, coord_index::Integer)
    @assert route_index >= 1 && coord_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_geometry_coordinate_longitude(response.ptr, Cuint(route_index - 1), Cuint(coord_index - 1), error_pointer(err))
    end
end

waypoint_count(response::RouteResponse) =
    Int(with_error() do err
        CWrapper.osrmc_route_response_waypoint_count(response.ptr, error_pointer(err))
    end)

function waypoint_latitude(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_waypoint_latitude(response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function waypoint_longitude(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_waypoint_longitude(response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function waypoint_name(response::RouteResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    cstr = with_error() do err
        CWrapper.osrmc_route_response_waypoint_name(response.ptr, Cuint(index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

function leg_count(response::RouteResponse, route_index::Integer = 1)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    Int(with_error() do err
        CWrapper.osrmc_route_response_leg_count(response.ptr, Cuint(route_index - 1), error_pointer(err))
    end)
end

function step_count(response::RouteResponse, route_index::Integer, leg_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 "Julia uses 1-based indexing"
    Int(with_error() do err
        CWrapper.osrmc_route_response_step_count(response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), error_pointer(err))
    end)
end

function step_distance(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_step_distance(response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
end

function step_duration(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    with_error() do err
        CWrapper.osrmc_route_response_step_duration(response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
end

function step_instruction(response::RouteResponse, route_index::Integer, leg_index::Integer, step_index::Integer)
    @assert route_index >= 1 && leg_index >= 1 && step_index >= 1 "Julia uses 1-based indexing"
    cstr = with_error() do err
        CWrapper.osrmc_route_response_step_instruction(response.ptr, Cuint(route_index - 1), Cuint(leg_index - 1), Cuint(step_index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

"""
    route(osrm::OSRM, params::RouteParams) -> RouteResponse

Calls the libosrmc Route endpoint directly, avoiding HTTP and keeping responses
in-memory.
"""
function route(osrm::OSRM, params::RouteParams)
    ptr = with_error() do err
        CWrapper.osrmc_route(osrm.ptr, params.ptr, error_pointer(err))
    end
    return RouteResponse(ptr)
end

"""
    as_json(response::RouteResponse) -> String

Provide the canonical OSRM JSON payload for logging or interoperability with
existing tooling.
"""
function as_json(response::RouteResponse)
    blob = with_error() do err
        CWrapper.osrmc_route_response_json(response.ptr, error_pointer(err))
    end
    return blob_to_string(blob)
end

"""
    route_with(osrm::OSRM, params::RouteParams, handler::Function, data::Any)

Streams each waypoint into a Julia callback, which mimics libosrm's C callback
API without exposing raw pointers.
"""
function route_with(osrm::OSRM, params::RouteParams, handler::Function, data::Any)
    response = route(osrm, params)
    count = waypoint_count(response)
    for idx in 1:count
        name = try
            waypoint_name(response, idx)
        catch
            ""
        end
        lat = waypoint_latitude(response, idx)
        lon = waypoint_longitude(response, idx)
        handler(data, name, Float32(lat), Float32(lon))
    end
    return nothing
end

end # module Route
