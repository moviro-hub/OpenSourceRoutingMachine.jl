"""
    TripResponse

Owns the raw libosrmc trip response pointer and ensures it is freed when the
Julia object goes out of scope.
"""
function _trip_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_trip_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct TripResponse
    ptr::Ptr{Cvoid}

    function TripResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TripResponse from NULL pointer")
        response = new(ptr)
        Utils.finalize(response, _trip_response_destruct)
        return response
    end
end

"""
    as_json(response::TripResponse) -> String
"""
function as_json(response::TripResponse)
    blob = with_error() do err
        ccall((:osrmc_trip_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return Utils.as_string(blob)
end

"""
    distance(response::TripResponse) -> Float64
"""
function distance(response::TripResponse)
    return with_error() do err
        ccall((:osrmc_trip_response_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
end

"""
    duration(response::TripResponse) -> Float64
"""
function duration(response::TripResponse)
    return with_error() do err
        ccall((:osrmc_trip_response_duration, libosrmc), Cdouble, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
end

"""
    waypoint_count(response::TripResponse) -> Int
"""
waypoint_count(response::TripResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_trip_response_waypoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)


function waypoint_latitude(response::TripResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_trip_response_waypoint_latitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function waypoint_longitude(response::TripResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    return with_error() do err
        ccall((:osrmc_trip_response_waypoint_longitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

"""
    waypoint_coordinate(response::TripResponse, index) -> LatLon
"""
function waypoint_coordinate(response::TripResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    lat = waypoint_latitude(response, index)
    lon = waypoint_longitude(response, index)
    return LatLon(lat, lon)
end
