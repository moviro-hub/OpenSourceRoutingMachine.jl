"""
Trip service wrapper.
"""
module Trip

using ..CWrapper
using ..Error: with_error, error_pointer
using ..Utils: blob_to_string, _finalize_response!
import ..Config: OSRM
import ..Params: TripParams
import ..Route: distance, duration

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
        _finalize_response!(response, CWrapper.osrmc_trip_response_destruct)
        return response
    end
end

"""
    distance(response::TripResponse) -> Float32
"""
distance(response::TripResponse) =
    with_error() do err
        CWrapper.osrmc_trip_response_distance(response.ptr, error_pointer(err))
    end

"""
    duration(response::TripResponse) -> Float32
"""
duration(response::TripResponse) =
    with_error() do err
        CWrapper.osrmc_trip_response_duration(response.ptr, error_pointer(err))
    end

"""
    waypoint_count(response::TripResponse) -> Int
"""
waypoint_count(response::TripResponse) =
    Int(with_error() do err
        CWrapper.osrmc_trip_response_waypoint_count(response.ptr, error_pointer(err))
    end)

"""
    waypoint_latitude(response::TripResponse, index) -> Float32
"""
function waypoint_latitude(response::TripResponse, index::Integer)
    with_error() do err
        CWrapper.osrmc_trip_response_waypoint_latitude(response.ptr, Cuint(index), error_pointer(err))
    end
end

"""
    waypoint_longitude(response::TripResponse, index) -> Float32
"""
function waypoint_longitude(response::TripResponse, index::Integer)
    with_error() do err
        CWrapper.osrmc_trip_response_waypoint_longitude(response.ptr, Cuint(index), error_pointer(err))
    end
end

"""
    trip(osrm::OSRM, params::TripParams) -> TripResponse

Query the Trip service and return a response object.
"""
function trip(osrm::OSRM, params::TripParams)
    ptr = with_error() do err
        CWrapper.osrmc_trip(osrm.ptr, params.ptr, error_pointer(err))
    end
    return TripResponse(ptr)
end

"""
    as_json(response::TripResponse) -> String
"""
function as_json(response::TripResponse)
    blob = with_error() do err
        CWrapper.osrmc_trip_response_json(response.ptr, error_pointer(err))
    end
    return blob_to_string(blob)
end

end # module Trip
