"""
    MatchResponse

Owns the raw libosrmc match response pointer and ensures it is freed exactly
once when the Julia object gets GC'd.
"""
function _match_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_match_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct MatchResponse
    ptr::Ptr{Cvoid}

    function MatchResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct MatchResponse from NULL pointer")
        response = new(ptr)
        finalize(response, _match_response_destruct)
        return response
    end
end

"""
    get_flatbuffer(response::MatchResponse) -> Vector{UInt8}

Returns the entire response as FlatBuffers binary data with zero-copy ownership transfer.
"""
function get_flatbuffer(response::MatchResponse)
    data_ptr_ref = Ref{Ptr{UInt8}}()
    size_ref = Ref{Csize_t}(0)
    deleter_pp_ref = Ref{Ptr{Cvoid}}(C_NULL)
    with_error() do err
        ccall((:osrmc_match_response_transfer_flatbuffer, libosrmc),
              Cvoid,
              (Ptr{Cvoid}, Ref{Ptr{UInt8}}, Ref{Csize_t}, Ref{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}),
              response.ptr, data_ptr_ref, size_ref, deleter_pp_ref, error_pointer(err))
    end
    return unsafe_wrap(Array, data_ptr_ref[], size_ref[]; own=true)
end
