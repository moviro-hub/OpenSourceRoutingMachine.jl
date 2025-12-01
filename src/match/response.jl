"""
    MatchResponse

Owns the raw libosrmc match response pointer and ensures it is freed exactly
once when the Julia object gets GC'd.
"""
function _match_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_match_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct MatchResponse
    ptr::Ptr{Cvoid}

    function MatchResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct MatchResponse from NULL pointer")
        response = new(ptr)
        Utils.finalize(response, _match_response_destruct)
        return response
    end
end

"""
    as_json(response::MatchResponse) -> String

Retrieve OSRM's canonical JSON payload for logging or compatibility with
existing tooling.
"""
function as_json(response::MatchResponse)
    blob = with_error() do err
        ccall((:osrmc_match_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return Utils.as_string(blob)
end

"""
    route_count(response::MatchResponse) -> Int

Expose the number of alternative routes without JSON parsing so callers can
preallocate downstream data structures.
"""
route_count(response::MatchResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_match_response_route_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    tracepoint_count(response::MatchResponse) -> Int

Reveal how many tracepoints OSRM accepted, which helps detect truncated GPS
streams early.
"""
tracepoint_count(response::MatchResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_match_response_tracepoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    route_distance(response::MatchResponse, route_index) -> Float64

Let OSRM be the source of truth for cumulative distance instead of re-integrating
coordinates client-side.
"""
function route_distance(response::MatchResponse, route_index::Integer)
    count = route_count(response)
    @assert 1 <= route_index <= count "Index $route_index out of bounds [1, $count]"
    return with_error() do err
        ccall((:osrmc_match_response_route_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

"""
    route_duration(response::MatchResponse, route_index) -> Float64

Reuses OSRM's travel time heuristics so Julia callers stay aligned with server
estimates.
"""
function route_duration(response::MatchResponse, route_index::Integer)
    count = route_count(response)
    @assert 1 <= route_index <= count "Index $route_index out of bounds [1, $count]"
    return with_error() do err
        ccall((:osrmc_match_response_route_duration, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

"""
    route_confidence(response::MatchResponse, route_index) -> Float64

Surface OSRM's built-in confidence metric so applications can fall back when a
match looks unreliable.
"""
function route_confidence(response::MatchResponse, route_index::Integer)
    count = route_count(response)
    @assert 1 <= route_index <= count "Index $route_index out of bounds [1, $count]"
    return with_error() do err
        ccall((:osrmc_match_response_route_confidence, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(route_index - 1), error_pointer(err))
    end
end

function tracepoint_latitude(response::MatchResponse, index::Integer)
    count = tracepoint_count(response)
    @assert 1 <= index <= count "Index $index out of bounds [1, $count]"
    return with_error() do err
        ccall((:osrmc_match_response_tracepoint_latitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function tracepoint_longitude(response::MatchResponse, index::Integer)
    count = tracepoint_count(response)
    @assert 1 <= index <= count "Index $index out of bounds [1, $count]"
    return with_error() do err
        ccall((:osrmc_match_response_tracepoint_longitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

"""
    tracepoint_coordinate(response::MatchResponse, index) -> LatLon

Return the latitude and longitude of the `index`-th tracepoint in the response.
"""
function tracepoint_coordinate(response::MatchResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    lat = tracepoint_latitude(response, index)
    lon = tracepoint_longitude(response, index)
    return LatLon(lat, lon)
end

"""
    tracepoint_is_null(response::MatchResponse, index) -> Bool

Flags unmatched points so callers can remove or interpolate them before further
processing.
"""
function tracepoint_is_null(response::MatchResponse, index::Integer)
    count = tracepoint_count(response)
    @assert 1 <= index <= count "Index $index out of bounds [1, $count]"
    result = with_error() do err
        ccall((:osrmc_match_response_tracepoint_is_null, libosrmc), Cint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
    return result != 0
end
