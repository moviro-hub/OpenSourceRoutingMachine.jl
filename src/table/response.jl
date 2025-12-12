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
        finalize(response, _table_response_destruct)
        return response
    end
end

"""
    get_format(response::TableResponse) -> OutputFormat

Returns the output format of the response (`json` or `flatbuffers`).
"""
function get_format(response::TableResponse)
    code = with_error() do err
        ccall((:osrmc_table_response_format, libosrmc), Cint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return OutputFormat(code)
end

"""
    get_json(response::TableResponse) -> String

Retrieve the entire response as JSON string.
"""
function get_json(response::TableResponse)
    blob = with_error() do err
        ccall((:osrmc_table_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    return as_string(blob)
end

"""
    get_flatbuffer(response::TableResponse) -> Vector{UInt8}

Returns the entire response as FlatBuffers binary data.
"""
function get_flatbuffer(response::TableResponse)
    blob = with_error() do err
        ccall((:osrmc_table_response_flatbuffer, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response.ptr, error_pointer(err))
    end
    data_ptr = ccall((:osrmc_blob_data, libosrmc), Ptr{Cchar}, (Ptr{Cvoid},), blob)
    len = ccall((:osrmc_blob_size, libosrmc), Csize_t, (Ptr{Cvoid},), blob)
    data = unsafe_wrap(Array, Ptr{UInt8}(data_ptr), len; own=false)
    result = Vector{UInt8}(undef, len)
    copyto!(result, data)
    ccall((:osrmc_blob_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), blob)
    return result
end
