"""
Typed wrapper around OSRM's Match service so callers can reuse the C API without
going through the HTTP server.
"""
module Match

using ..CWrapper: CWrapper
using ..Error: Error
using ..Utils: Utils
using ..Config: Config
using ..Params: Params
import Base: match

"""
    MatchResponse

Owns the raw libosrmc match response pointer and ensures it is freed exactly
once when the Julia object gets GC'd.
"""
mutable struct MatchResponse
    ptr::Ptr{Cvoid}

    function MatchResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct MatchResponse from NULL pointer")
        response = new(ptr)
        Utils._finalize_response!(response, CWrapper.osrmc_match_response_destruct)
        return response
    end
end

"""
    route_count(response::MatchResponse) -> Int

Expose the number of alternative routes without JSON parsing so callers can
preallocate downstream data structures.
"""
route_count(response::MatchResponse) =
    Int(    Error.with_error() do err
        CWrapper.osrmc_match_response_route_count(response.ptr, Error.error_pointer(err))
    end)

"""
    tracepoint_count(response::MatchResponse) -> Int

Reveal how many tracepoints OSRM accepted, which helps detect truncated GPS
streams early.
"""
tracepoint_count(response::MatchResponse) =
    Int(Error.with_error() do err
        CWrapper.osrmc_match_response_tracepoint_count(response.ptr, Error.error_pointer(err))
    end)

"""
    route_distance(response::MatchResponse, route_index) -> Float32

Let OSRM be the source of truth for cumulative distance instead of re-integrating
coordinates client-side.
"""
function route_distance(response::MatchResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_match_response_route_distance(response.ptr, Cuint(route_index - 1), Error.error_pointer(err))
    end
end

"""
    route_duration(response::MatchResponse, route_index) -> Float32

Reuses OSRM's travel time heuristics so Julia callers stay aligned with server
estimates.
"""
function route_duration(response::MatchResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_match_response_route_duration(response.ptr, Cuint(route_index - 1), Error.error_pointer(err))
    end
end

"""
    route_confidence(response::MatchResponse, route_index) -> Float32

Surface OSRM's built-in confidence metric so applications can fall back when a
match looks unreliable.
"""
function route_confidence(response::MatchResponse, route_index::Integer)
    @assert route_index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_match_response_route_confidence(response.ptr, Cuint(route_index - 1), Error.error_pointer(err))
    end
end

"""
    tracepoint_latitude(response::MatchResponse, index) -> Float32

Inspect where OSRM snapped a point without leaving Julia, useful for debugging
GPS drift.
"""
function tracepoint_latitude(response::MatchResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_match_response_tracepoint_latitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    tracepoint_longitude(response::MatchResponse, index) -> Float32

Pairs with `tracepoint_latitude` to reconstruct snapped coordinates for
visualization layers.
"""
function tracepoint_longitude(response::MatchResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_match_response_tracepoint_longitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    tracepoint_is_null(response::MatchResponse, index) -> Bool

Flags unmatched points so callers can remove or interpolate them before further
processing.
"""
function tracepoint_is_null(response::MatchResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    result = Error.with_error() do err
        CWrapper.osrmc_match_response_tracepoint_is_null(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
    return result != 0
end

"""
    match(osrm::OSRM, params::MatchParams) -> MatchResponse

Extends `Base.match` so callers can invoke OSRM's native matcher directly and
receive a typed response without HTTP hops.
"""
function match(osrm::Config.OSRM, params::Params.MatchParams)
    ptr = Error.with_error() do err
        CWrapper.osrmc_match(osrm.ptr, params.ptr, Error.error_pointer(err))
    end
    return MatchResponse(ptr)
end

"""
    as_json(response::MatchResponse) -> String

Retrieve OSRM's canonical JSON payload for logging or compatibility with
existing tooling.
"""
function as_json(response::MatchResponse)
    blob = Error.with_error() do err
        CWrapper.osrmc_match_response_json(response.ptr, Error.error_pointer(err))
    end
    return Utils.blob_to_string(blob)
end

is_supported() = true

end # module Match
