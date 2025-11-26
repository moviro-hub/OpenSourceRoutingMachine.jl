"""
Error handling for libosrmc wrapper.
"""
module Error

using ..CWrapper

export OSRMError, check_error, take_error!, with_error, error_pointer

"""
    OSRMError <: Exception

Wraps libosrmc error code/message pairs so callers get structured exceptions
instead of parsing raw strings.
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

libosrmc expects a `Ptr{Ptr{Cvoid}}`; this hides the conversion so the rest of
the code can treat errors like normal `Ref`s.
"""
@inline function error_pointer(error_ref::Ref{Ptr{Cvoid}})
    return Base.unsafe_convert(Ptr{Ptr{Cvoid}}, error_ref)
end

"""
    take_error!(error_ref::Ref{Ptr{Cvoid}}) -> Union{OSRMError, Nothing}

Extract and clear the underlying libosrmc error so callers can decide whether
to throw, log, or aggregate failures.
"""
function take_error!(error_ref::Ref{Ptr{Cvoid}})
    error_obj = error_ref[]
    error_obj == C_NULL && return nothing

    code_str = unsafe_string(CWrapper.osrmc_error_code(error_obj))
    msg_str = unsafe_string(CWrapper.osrmc_error_message(error_obj))
    CWrapper.osrmc_error_destruct(error_obj)
    error_ref[] = C_NULL

    return OSRMError(code_str, msg_str)
end

"""
    check_error(error_ref::Ref{Ptr{Cvoid}})

Raise immediately when libosrmc signaled a failure; keeps callers from silently
continuing with partially initialized state.
"""
function check_error(error_ref::Ref{Ptr{Cvoid}})
    err = take_error!(error_ref)
    return err === nothing || throw(err)
end

"""
    with_error(f::Function) -> result

Runs `f(error_ref)` while automatically wiring up error allocation/cleanup so
callers only express their success path.
"""
function with_error(f::Function)
    error_ref = Ref{Ptr{Cvoid}}(C_NULL)
    result = f(error_ref)
    check_error(error_ref)
    return result
end

"""
    with_error(f::Function, args...) -> result

Same as `with_error(f)` but forwards additional arguments to avoid anonymous
closures at call sites.
"""
function with_error(f::Function, args...)
    with_error(er -> f(er, args...))
end

"""
    @check_error expr

Turns a manual `Ref` + `check_error` sequence into a single expression, making
it harder to forget cleanup after `ccall`.
"""
macro check_error(expr)
    error_mod = @__MODULE__
    return quote
        error_ptr = Ref{Ptr{Cvoid}}(C_NULL)
        result = $(esc(expr))
        $error_mod.check_error(error_ptr)
        result
    end
end

end
