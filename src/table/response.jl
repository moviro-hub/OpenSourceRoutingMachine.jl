"""
    TableResponse

Owns the libosrmc table response pointer and releases it when the Julia object
gets garbage collected.
"""
function _table_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_table_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct TableResponse
    ptr::Ptr{Cvoid}

    function TableResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TableResponse from NULL pointer")
        response = new(ptr)
        Utils.finalize(response, _table_response_destruct)
        return response
    end
end

"""
    as_json(response::TableResponse) -> String

Retrieve the canonical OSRM JSON payload for logging or interoperability.
"""
function as_json(response::TableResponse)
    blob = with_error() do err
        ccall((:osrmc_table_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return Utils.as_string(blob)
end

"""
    source_count(response) -> Int

Helps verify how many origins OSRM accepted before attempting to read matrices.
"""
source_count(response::TableResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_table_response_source_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    destination_count(response) -> Int

Same as `source_count` but for destinations, keeping sanity checks symmetric.
"""
destination_count(response::TableResponse) =
    Int(
    with_error() do err
        ccall((:osrmc_table_response_destination_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end,
)

"""
    duration(response, from, to) -> Float64

Return OSRM's travel time between two matrix indices so we stay consistent with
the engine (returns `Inf` when no route exists).
"""
function duration(response::TableResponse, from::Integer, to::Integer)
    return with_error() do err
        ccall((:osrmc_table_response_duration, libosrmc), Cdouble, (Ptr{Cvoid}, Culong, Culong, Ptr{Ptr{Cvoid}}), response.ptr, Culong(from - 1), Culong(to - 1), error_pointer(err))
    end
end

"""
    distance(response, from, to) -> Float64

Expose the meters-between calculation OSRM already computed for the matrix.
"""
function distance(response::TableResponse, from::Integer, to::Integer)
    return with_error() do err
        ccall((:osrmc_table_response_distance, libosrmc), Cdouble, (Ptr{Cvoid}, Culong, Culong, Ptr{Ptr{Cvoid}}), response.ptr, Culong(from - 1), Culong(to - 1), error_pointer(err))
    end
end

"""
    duration_matrix(response) -> Matrix{Float64}

Fill an existing `Float64` buffer (vector or matrix, row-major) with durations
so callers can avoid allocations when repeatedly querying OSRM.
"""
function duration_matrix(response::TableResponse)
    n = source_count(response)
    m = destination_count(response)
    expected = n * m
    buffer = Vector{Float64}(undef, expected)
    count = with_error() do err
        ccall((:osrmc_table_response_get_duration_matrix, libosrmc), Cint, (Ptr{Cvoid}, Ptr{Cdouble}, Csize_t, Ptr{Ptr{Cvoid}}), response.ptr, pointer(buffer), Csize_t(expected), error_pointer(err))
    end
    count == expected || error("Duration matrix: expected $expected elements, got $count")
    return transpose(reshape(buffer, m, n))
end

"""
    distance_matrix(response) -> Matrix{Float64}

In-place variant for distances, mirroring `duration_matrix` to support
allocation-free bulk work.
"""
function distance_matrix(response::TableResponse)
    n = source_count(response)
    m = destination_count(response)
    expected = n * m
    buffer = Vector{Float64}(undef, expected)
    count = with_error() do err
        ccall((:osrmc_table_response_get_distance_matrix, libosrmc), Cint, (Ptr{Cvoid}, Ptr{Cdouble}, Csize_t, Ptr{Ptr{Cvoid}}), response.ptr, pointer(buffer), Csize_t(expected), error_pointer(err))
    end
    count == expected || error("Distance matrix: expected $expected elements, got $count")
    return transpose(reshape(buffer, m, n))
end
