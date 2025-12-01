"""
    NearestResponse

Owns the libosrmc nearest response pointer and frees it automatically when the
object is garbage collected.
"""
function _nearest_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_nearest_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct NearestResponse
    ptr::Ptr{Cvoid}

    function NearestResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct NearestResponse from NULL pointer")
        response = new(ptr)
        Utils.finalize(response, _nearest_response_destruct)
        return response
    end
end

"""
    as_json(response::NearestResponse) -> String

Returns the entire response as JSON string.
"""
function as_json(response::NearestResponse)
    blob = with_error() do err
        ccall((:osrmc_nearest_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return Utils.as_string(blob)
end

"""
    get_count(response::NearestResponse) -> Int

Extends `Base.count` so callers can ask how many nearest hits OSRM returned
without parsing JSON payloads.
"""
get_count(response::NearestResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_nearest_response_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

function get_latitude(response::NearestResponse, index::Integer)
    n = get_count(response)
    @assert 1 <= index <= n "Index $index out of bounds [1, $n]"
    return with_error() do err
        ccall((:osrmc_nearest_response_latitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

function get_longitude(response::NearestResponse, index::Integer)
    n = get_count(response)
    @assert 1 <= index <= n "Index $index out of bounds [1, $n]"
    return with_error() do err
        ccall((:osrmc_nearest_response_longitude, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

"""
    get_coordinate(response::NearestResponse, index) -> LatLon

Return the latitude and longitude of the `index`-th nearest point in the response.
"""
function get_coordinate(response::NearestResponse, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    lat = get_latitude(response, index)
    lon = get_longitude(response, index)
    return LatLon(lat, lon)
end

"""
    get_name(response::NearestResponse, index) -> String

Pull the textual label directly from OSRM to keep UI strings consistent with
the engine.
"""
function get_name(response::NearestResponse, index::Integer)
    n = get_count(response)
    @assert 1 <= index <= n "Index $index out of bounds [1, $n]"
    cstr = with_error() do err
        ccall((:osrmc_nearest_response_name, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
    return unsafe_string(cstr)
end

"""
    get_distance(response::NearestResponse, index) -> Float64

Reuse OSRM's precomputed meters-to-target instead of recomputing client-side.
"""
function get_distance(response::NearestResponse, index::Integer)
    n = get_count(response)
    @assert 1 <= index <= n "Index $index out of bounds [1, $n]"
    return with_error() do err
        ccall((:osrmc_nearest_response_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
end

"""
    get_hint(response::NearestResponse, index) -> String

Returns the base64-encoded hint produced by OSRM so callers can reuse it for
follow-up queries.
"""
function get_hint(response::NearestResponse, index::Integer)
    n = get_count(response)
    @assert 1 <= index <= n "Index $index out of bounds [1, $n]"
    cstr = with_error() do err
        ccall((:osrmc_nearest_response_hint, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response.ptr, Cuint(index - 1), error_pointer(err))
    end
    return cstr == C_NULL ? "" : unsafe_string(cstr)
end
