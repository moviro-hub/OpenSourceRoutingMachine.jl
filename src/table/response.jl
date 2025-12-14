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
    get_flatbuffer(response::TableResponse) -> Vector{UInt8}

Returns the entire response as FlatBuffers binary data with zero-copy ownership transfer.
"""
function get_flatbuffer(response::TableResponse)
    data_ptr_ref = Ref{Ptr{UInt8}}()
    size_ref = Ref{Csize_t}(0)
    deleter_pp_ref = Ref{Ptr{Cvoid}}(C_NULL)
    with_error() do err
        ccall((:osrmc_table_response_transfer_flatbuffer, libosrmc),
              Cvoid,
              (Ptr{Cvoid}, Ref{Ptr{UInt8}}, Ref{Csize_t}, Ref{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}),
              response.ptr, data_ptr_ref, size_ref, deleter_pp_ref, error_pointer(err))
    end
    return unsafe_wrap(Array, data_ptr_ref[], size_ref[]; own=true)
end
