"""
    as_string(blob) -> String

Takes ownership of a libosrm blob and returns a Julia String, guaranteeing the
blob is freed exactly once.
"""
function as_string(blob)
    data_ptr = ccall((:osrmc_blob_data, libosrmc), Ptr{Cchar}, (Ptr{Cvoid},), blob)
    len = ccall((:osrmc_blob_size, libosrmc), Csize_t, (Ptr{Cvoid},), blob)
    str = unsafe_string(Ptr{UInt8}(data_ptr), len)
    ccall((:osrmc_blob_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), blob)
    return str
end

@inline function as_cstring(str::AbstractString)
    cstr = Base.cconvert(Cstring, str)
    return Base.unsafe_convert(Cstring, cstr)
end

@inline function as_cstring_or_null(str::Union{AbstractString, Nothing})
    return str === nothing ? C_NULL : as_cstring(str)
end

@inline as_cint(flag::Bool) = flag ? Cint(1) : Cint(0)

"""
    finalize(owner, destructor)

Installs a GC finalizer for `owner` that invokes `destructor` on its `ptr`
field. This is used by both parameter and response wrappers to ensure native
handles always get released exactly once.
"""
function finalize(owner, destructor)
    return finalizer(owner) do obj
        if obj.ptr != C_NULL
            destructor(obj.ptr)
            obj.ptr = C_NULL
        end
    end
end
