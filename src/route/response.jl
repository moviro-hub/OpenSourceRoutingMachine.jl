"""
    RouteResponse

Owns the libosrmc route response pointer and cleans it up automatically when
the Julia object is collected.
"""
function _route_response_destruct(ptr::Ptr{Cvoid})
    ccall((:osrmc_route_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), ptr)
    return nothing
end

mutable struct RouteResponse
    ptr::Ptr{Cvoid}

    function RouteResponse(ptr::Ptr{Cvoid})
        ptr == C_NULL && error("Cannot construct RouteResponse from NULL pointer")
        response = new(ptr)
        finalize(response, _route_response_destruct)
        return response
    end
end

"""
    get_flatbuffer(response::RouteResponse) -> Vector{UInt8}

Returns the entire response as FlatBuffers binary data with zero-copy ownership transfer.
"""
function get_flatbuffer(response::RouteResponse)
    data_ptr_ref = Ref{Ptr{UInt8}}()
    size_ref = Ref{Csize_t}(0)
    # deleter is a pointer to a function pointer: void (**deleter)(void*)
    deleter_pp_ref = Ref{Ptr{Cvoid}}(C_NULL)
    with_error() do err
        ccall((:osrmc_route_response_transfer_flatbuffer, libosrmc),
              Cvoid,
              (Ptr{Cvoid}, Ref{Ptr{UInt8}}, Ref{Csize_t}, Ref{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}),
              response.ptr, data_ptr_ref, size_ref, deleter_pp_ref, error_pointer(err))
    end
    # The deleter is set by C code to std::free, so we use free directly
    # Zero-copy: Julia owns the memory (freed automatically when Array is GC'd using free)
    return unsafe_wrap(Array, data_ptr_ref[], size_ref[]; own=true)
end
