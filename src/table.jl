"""
Wrapper around OSRM's Table service so we can compute matrices without HTTP or
JSON overhead.
"""
module Table

using ..CWrapper: CWrapper
using ..Error: Error
using ..Utils: Utils
using ..Config: Config
using ..Params: Params
import ..OpenSourceRoutingMachine: duration, distance, as_json

export
    TableResponse,
    table,
    as_json,
    source_count,
    destination_count,
    duration,
    distance,
    duration_matrix!,
    distance_matrix!

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
        Utils._finalize_response!(response, CWrapper.osrmc_table_response_destruct)
        return response
    end
end

"""
    table(osrm::OSRM, params::TableParams) -> TableResponse

Calls libosrmc's Table endpoint directly, keeping the full response in-memory
instead of going through osrm-routed.
"""
function table(osrm::Config.OSRM, params::Params.TableParams)
    ptr = Error.with_error() do err
        CWrapper.osrmc_table(osrm.ptr, params.ptr, Error.error_pointer(err))
    end
    return TableResponse(ptr)
end

"""
    as_json(response::TableResponse) -> String

Retrieve the canonical OSRM JSON payload for logging or interoperability.
"""
function as_json(response::TableResponse)
    blob = Error.with_error() do err
        CWrapper.osrmc_table_response_json(response.ptr, Error.error_pointer(err))
    end
    return Utils.blob_to_string(blob)
end

"""
    source_count(response) -> Int

Helps verify how many origins OSRM accepted before attempting to read matrices.
"""
source_count(response::TableResponse) =
    Int(
    Error.with_error() do err
        CWrapper.osrmc_table_response_source_count(response.ptr, Error.error_pointer(err))
    end
)

"""
    destination_count(response) -> Int

Same as `source_count` but for destinations, keeping sanity checks symmetric.
"""
destination_count(response::TableResponse) =
    Int(
    Error.with_error() do err
        CWrapper.osrmc_table_response_destination_count(response.ptr, Error.error_pointer(err))
    end
)

"""
    duration(response, from, to) -> Float32

Return OSRM's travel time between two matrix indices so we stay consistent with
the engine (returns `Inf` when no route exists).
"""
function duration(response::TableResponse, from::Integer, to::Integer)
    return Error.with_error() do err
        CWrapper.osrmc_table_response_duration(response.ptr, Culong(from - 1), Culong(to - 1), Error.error_pointer(err))
    end
end

"""
    distance(response, from, to) -> Float32

Expose the meters-between calculation OSRM already computed for the matrix.
"""
function distance(response::TableResponse, from::Integer, to::Integer)
    return Error.with_error() do err
        CWrapper.osrmc_table_response_distance(response.ptr, Culong(from - 1), Culong(to - 1), Error.error_pointer(err))
    end
end

"""
    duration_matrix(response) -> Matrix{Float32}

Fill an existing `Float32` buffer (vector or matrix, row-major) with durations
so callers can avoid allocations when repeatedly querying OSRM.
"""
function duration_matrix(response::TableResponse)
    n = source_count(response)
    m = destination_count(response)
    expected = n * m
    buffer = Vector{Float32}(undef, expected)
    count = Error.with_error() do err
        CWrapper.osrmc_table_response_get_duration_matrix(response.ptr, pointer(buffer), Csize_t(expected), Error.error_pointer(err))
    end
    count == expected || error("Duration matrix: expected $expected elements, got $count")
    return transpose(reshape(buffer, m, n))
end

"""
    distance_matrix(response) -> Matrix{Float32}

In-place variant for distances, mirroring `duration_matrix!` to support
allocation-free bulk work.
"""
function distance_matrix(response::TableResponse)
    n = source_count(response)
    m = destination_count(response)
    expected = n * m
    buffer = Vector{Float32}(undef, expected)
    count = Error.with_error() do err
        CWrapper.osrmc_table_response_get_distance_matrix(response.ptr, pointer(buffer), Csize_t(expected), Error.error_pointer(err))
    end
    count == expected || error("Distance matrix: expected $expected elements, got $count")
    return transpose(reshape(buffer, m, n))
end

end # module Table
