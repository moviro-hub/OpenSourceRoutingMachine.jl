"""
Typed wrapper around OSRM's Nearest service so callers can run proximity
queries without leaving Julia.
"""
module Nearest

using ..CWrapper: CWrapper
using ..Error: Error
using ..Utils: Utils
using ..Config: Config
using ..Params: Params
import ..OpenSourceRoutingMachine: distance
import Base: count

"""
    NearestResponse

Owns the libosrmc nearest response pointer and frees it automatically when the
object is garbage collected.
"""
mutable struct NearestResponse
    ptr::Ptr{Cvoid}

    function NearestResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct NearestResponse from NULL pointer")
        response = new(ptr)
        Utils._finalize_response!(response, CWrapper.osrmc_nearest_response_destruct)
        return response
    end
end

"""
    count(response::NearestResponse) -> Int

Extends `Base.count` so callers can ask how many nearest hits OSRM returned
without parsing JSON payloads.
"""
count(response::NearestResponse) =
    Int(
    Error.with_error() do err
        CWrapper.osrmc_nearest_response_count(response.ptr, Error.error_pointer(err))
    end
)

"""
    latitude(response::NearestResponse, index) -> Float32

Inspect OSRM's snapped latitude to diagnose how the engine chose a candidate.
"""
function latitude(response::NearestResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return Error.with_error() do err
        CWrapper.osrmc_nearest_response_latitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    longitude(response::NearestResponse, index) -> Float32

Pairs with `latitude` to reconstruct snapped coordinates for visualization.
"""
function longitude(response::NearestResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return Error.with_error() do err
        CWrapper.osrmc_nearest_response_longitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    name(response::NearestResponse, index) -> String

Pull the textual label directly from OSRM to keep UI strings consistent with
the engine.
"""
function name(response::NearestResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    cstr = Error.with_error() do err
        CWrapper.osrmc_nearest_response_name(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
    return unsafe_string(cstr)
end

"""
    distance(response::NearestResponse, index) -> Float32

Reuse OSRM's precomputed meters-to-target instead of recomputing client-side.
"""
function distance(response::NearestResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return Error.with_error() do err
        CWrapper.osrmc_nearest_response_distance(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    nearest(osrm::OSRM, params::NearestParams) -> NearestResponse

Calls the libosrmc Nearest endpoint directly, avoiding HTTP round-trips.
"""
function nearest(osrm::Config.OSRM, params::Params.NearestParams)
    ptr = Error.with_error() do err
        CWrapper.osrmc_nearest(osrm.ptr, params.ptr, Error.error_pointer(err))
    end
    return NearestResponse(ptr)
end

"""
    as_json(response::NearestResponse) -> String

Returns the canonical JSON emitted by OSRM so the result can be logged or fed
into tooling that expects server responses.
"""
function as_json(response::NearestResponse)
    blob = Error.with_error() do err
        CWrapper.osrmc_nearest_response_json(response.ptr, Error.error_pointer(err))
    end
    return Utils.blob_to_string(blob)
end

is_supported() = true

end # module Nearest
