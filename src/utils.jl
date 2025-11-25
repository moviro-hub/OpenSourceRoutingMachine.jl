"""
Utility helpers that centralize blob-to-string conversion and response
finalization so we don't repeat unsafe pointer logic throughout the codebase.
"""
module Utils

using ..CWrapper

"""
    blob_to_string(blob) -> String

Takes ownership of a libosrm blob and returns a Julia String, guaranteeing the
blob is freed exactly once.
"""
function blob_to_string(blob)
    data_ptr = CWrapper.osrmc_blob_data(blob)
    len = CWrapper.osrmc_blob_size(blob)
    str = unsafe_string(Ptr{UInt8}(data_ptr), len)
    CWrapper.osrmc_blob_destruct(blob)
    return str
end

"""
    _finalize_response!(response, destructor)

Installs a GC finalizer that runs the provided destructor so libosrm responses
can't leak even if callers forget to free them.
"""
function _finalize_response!(response, destructor)
    finalizer(response) do r
        if r.ptr != C_NULL
            destructor(r.ptr)
            r.ptr = C_NULL
        end
    end
end

end # module Utils
