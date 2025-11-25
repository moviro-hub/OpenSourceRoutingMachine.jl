"""
Wrapper around OSRM's Table service so we can compute matrices without HTTP or
JSON overhead.
"""
module Table

using ..CWrapper
using ..Error: with_error, error_pointer
using ..Utils: blob_to_string, _finalize_response!
import ..Config: OSRM
import ..Params: TableParams

"""
    TableResponse

Owns the libosrmc table response pointer and releases it when the Julia object
gets garbage collected.
"""
mutable struct TableResponse
    ptr::Ptr{Cvoid}

    function TableResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct TableResponse from NULL pointer")
        response = new(ptr)
        _finalize_response!(response, CWrapper.osrmc_table_response_destruct)
        return response
    end
end

"""
    source_count(response) -> Int

Helps verify how many origins OSRM accepted before attempting to read matrices.
"""
source_count(response::TableResponse) =
    Int(with_error() do err
        CWrapper.osrmc_table_response_source_count(response.ptr, error_pointer(err))
    end)

"""
    destination_count(response) -> Int

Same as `source_count` but for destinations, keeping sanity checks symmetric.
"""
destination_count(response::TableResponse) =
    Int(with_error() do err
        CWrapper.osrmc_table_response_destination_count(response.ptr, error_pointer(err))
    end)

"""
    duration(response, from, to) -> Float32

Return OSRM's travel time between two matrix indices so we stay consistent with
the engine (returns `Inf` when no route exists).
"""
function duration(response::TableResponse, from::Integer, to::Integer)
    with_error() do err
        CWrapper.osrmc_table_response_duration(response.ptr, Culong(from), Culong(to), error_pointer(err))
    end
end

"""
    distance(response, from, to) -> Float32

Expose the meters-between calculation OSRM already computed for the matrix.
"""
function distance(response::TableResponse, from::Integer, to::Integer)
    with_error() do err
        CWrapper.osrmc_table_response_distance(response.ptr, Culong(from), Culong(to), error_pointer(err))
    end
end

"""
    duration_matrix!(buffer, response) -> buffer

Fill an existing `Float32` buffer (vector or matrix, row-major) with durations
so callers can avoid allocations when repeatedly querying OSRM.
"""
function duration_matrix!(buffer::AbstractVector{Float32}, response::TableResponse)
    status = with_error() do err
        CWrapper.osrmc_table_response_get_duration_matrix(response.ptr, pointer(buffer), length(buffer), error_pointer(err))
    end
    status == 0 || error("Duration matrix buffer too small")
    buffer
end

function duration_matrix!(buffer::AbstractMatrix{Float32}, response::TableResponse)
    duration_matrix!(vec(buffer), response)
    buffer
end

"""
    distance_matrix!(buffer, response) -> buffer

In-place variant for distances, mirroring `duration_matrix!` to support
allocation-free bulk work.
"""
function distance_matrix!(buffer::AbstractVector{Float32}, response::TableResponse)
    status = with_error() do err
        CWrapper.osrmc_table_response_get_distance_matrix(response.ptr, pointer(buffer), length(buffer), error_pointer(err))
    end
    status == 0 || error("Distance matrix buffer too small")
    buffer
end

function distance_matrix!(buffer::AbstractMatrix{Float32}, response::TableResponse)
    distance_matrix!(vec(buffer), response)
    buffer
end

"""
    as_json(response::TableResponse) -> String

Retrieve the canonical OSRM JSON payload for logging or interoperability.
"""
function as_json(response::TableResponse)
    blob = with_error() do err
        CWrapper.osrmc_table_response_json(response.ptr, error_pointer(err))
    end
    return blob_to_string(blob)
end

"""
    table(osrm::OSRM, params::TableParams) -> TableResponse

Calls libosrmc's Table endpoint directly, keeping the full response in-memory
instead of going through osrm-routed.
"""
function table(osrm::OSRM, params::TableParams)
    ptr = with_error() do err
        CWrapper.osrmc_table(osrm.ptr, params.ptr, error_pointer(err))
    end
    return TableResponse(ptr)
end

end # module Table
