"""
Trip service wrapper.
"""
module Trip

using ..CWrapper: CWrapper
using ..Error: Error
using ..Utils: Utils
using ..Config: Config
using ..Params: Params
import ..OpenSourceRoutingMachine: distance, duration

"""
    TripResponse

Owns the raw libosrmc trip response pointer and ensures it is freed when the
Julia object goes out of scope.
"""
mutable struct TripResponse
    ptr::Ptr{Cvoid}

    function TripResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TripResponse from NULL pointer")
        response = new(ptr)
        Utils._finalize_response!(response, CWrapper.osrmc_trip_response_destruct)
        return response
    end
end

"""
    distance(response::TripResponse) -> Float32
"""
function distance(response::TripResponse)
    Error.with_error() do err
        CWrapper.osrmc_trip_response_distance(response.ptr, Error.error_pointer(err))
    end
end

"""
    duration(response::TripResponse) -> Float32
"""
function duration(response::TripResponse)
    Error.with_error() do err
        CWrapper.osrmc_trip_response_duration(response.ptr, Error.error_pointer(err))
    end
end

"""
    waypoint_count(response::TripResponse) -> Int
"""
waypoint_count(response::TripResponse) =
    Int(Error.with_error() do err
        CWrapper.osrmc_trip_response_waypoint_count(response.ptr, Error.error_pointer(err))
    end)

"""
    waypoint_latitude(response::TripResponse, index) -> Float32
"""
function waypoint_latitude(response::TripResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_trip_response_waypoint_latitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    waypoint_longitude(response::TripResponse, index) -> Float32
"""
function waypoint_longitude(response::TripResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    Error.with_error() do err
        CWrapper.osrmc_trip_response_waypoint_longitude(response.ptr, Cuint(index - 1), Error.error_pointer(err))
    end
end

"""
    trip(osrm::OSRM, params::TripParams) -> TripResponse

Query the Trip service and return a response object.
"""
function trip(osrm::Config.OSRM, params::Params.TripParams)
    ptr = Error.with_error() do err
        CWrapper.osrmc_trip(osrm.ptr, params.ptr, Error.error_pointer(err))
    end
    return TripResponse(ptr)
end

"""
    as_json(response::TripResponse) -> String
"""
function as_json(response::TripResponse)
    blob = Error.with_error() do err
        CWrapper.osrmc_trip_response_json(response.ptr, Error.error_pointer(err))
    end
    return Utils.blob_to_string(blob)
end

end # module Trip
