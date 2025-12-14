# string helpers
@inline function as_cstring(str::AbstractString)
    cstr = Base.cconvert(Cstring, str)
    return Base.unsafe_convert(Cstring, cstr)
end

@inline function as_cstring_or_null(str::Union{AbstractString, Nothing})
    return str === nothing ? C_NULL : as_cstring(str)
end

# data access helpers removed - now using direct access APIs

# error helpers
"""
    OSRMError(code, message)

Represents an error returned by libosrmc. `code` and `message` come directly from
the native library so callers can display meaningful diagnostics.
"""
struct OSRMError <: Exception
    code::String
    message::String
end

function Base.showerror(io::IO, e::OSRMError)
    return print(io, "OSRMError: [$(e.code)] $(e.message)")
end

"""
    error_pointer(error_ref) -> Ptr{Ptr{Cvoid}}

Lifts a `Ref{Ptr{Cvoid}}` so it can be passed to `ccall` error parameters.
"""
@inline error_pointer(error_ref::Ref{Ptr{Cvoid}}) = Base.unsafe_convert(Ptr{Ptr{Cvoid}}, error_ref)

"""
    take_error!(error_ref) -> Union{OSRMError, Nothing}

Consumes the native error object referenced by `error_ref`, converts it into an
`OSRMError`, and frees the underlying resource.
"""
function take_error!(error_ref::Ref{Ptr{Cvoid}})
    error_obj = error_ref[]
    error_obj == C_NULL && return nothing

    code_str = unsafe_string(ccall((:osrmc_error_code, libosrmc), Cstring, (Ptr{Cvoid},), error_obj))
    msg_str = unsafe_string(ccall((:osrmc_error_message, libosrmc), Cstring, (Ptr{Cvoid},), error_obj))
    ccall((:osrmc_error_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), error_obj)
    error_ref[] = C_NULL

    return OSRMError(code_str, msg_str)
end

"""
    check_error(error_ref)

Throws an `OSRMError` if `error_ref` points to a native error.
"""
function check_error(error_ref::Ref{Ptr{Cvoid}})
    err = take_error!(error_ref)
    return err !== nothing && throw(err)
end

"""
    with_error(f) -> Any

Allocates a native error pointer, passes it to `f`, and raises an `OSRMError`
when the C-side reports a failure.
"""
function with_error(f::Function)
    error_ref = Ref{Ptr{Cvoid}}(C_NULL)
    result = f(error_ref)
    check_error(error_ref)
    return result
end

# finalize helpers
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
