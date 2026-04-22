# FlatBuffers helpers
function as_struct(buffer::Vector{UInt8})::FBResult
    if isempty(buffer)
        error("Empty buffer provided")
    end

    # Use FlatBuffers.deserialize to parse the buffer
    # IOBuffer is efficient - it wraps the Vector without copying
    # Alternative: could use pointer(buffer) if FlatBuffers.deserialize supports it
    io = IOBuffer(buffer; read = true, write = false)
    result = FlatBuffers.deserialize(io, FBResult)

    # Check for errors
    if result.error
        if result.code !== nothing && result.code.message !== nothing
            error("OSRM Error: $(result.code.message)")
        else
            error("OSRM Error: Unknown error (error flag set but no error message)")
        end
    end

    return result
end

# string helpers
@inline function with_cstring_or_null(f, str::Union{AbstractString, Nothing})
    if str === nothing
        return f(Cstring(C_NULL))
    else
        cstr = Base.cconvert(Cstring, str)
        GC.@preserve cstr begin
            return f(Base.unsafe_convert(Cstring, cstr))
        end
    end
end

# data access helpers removed - now using direct access APIs

# error helpers
"""
    OSRMError(code, message)

Error returned by libosrmc with code and message from the native library.
"""
struct OSRMError <: Exception
    code::String
    message::String
end

function Base.showerror(io::IO, e::OSRMError)
    return print(io, "OSRMError: [$(e.code)] $(e.message)")
end

@inline error_pointer(error_ref::Ref{Ptr{Cvoid}}) = Base.unsafe_convert(Ptr{Ptr{Cvoid}}, error_ref)

function take_error!(error_ref::Ref{Ptr{Cvoid}})
    error_obj = error_ref[]
    error_obj == C_NULL && return nothing

    try
        code_str = unsafe_string(ccall((:osrmc_error_code, libosrmc), Cstring, (Ptr{Cvoid},), error_obj))
        msg_str = unsafe_string(ccall((:osrmc_error_message, libosrmc), Cstring, (Ptr{Cvoid},), error_obj))
        return OSRMError(code_str, msg_str)
    finally
        ccall((:osrmc_error_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), error_obj)
        error_ref[] = C_NULL
    end
end

function check_error(error_ref::Ref{Ptr{Cvoid}})
    err = take_error!(error_ref)
    err !== nothing && throw(err)
    return nothing
end

function with_error(f::Function)
    error_ref = Ref{Ptr{Cvoid}}(C_NULL)
    result = f(error_ref)
    check_error(error_ref)
    return result
end

# finalize helpers
function finalize(owner, destructor)
    return finalizer(owner) do obj
        if obj.ptr != C_NULL
            destructor(obj.ptr)
            obj.ptr = C_NULL
        end
    end
end

function verbosity_string_to_enum(verbosity::String)
    verbosity_upper = uppercase(verbosity)
    if verbosity_upper == "NONE"
        return VERBOSITY_NONE
    elseif verbosity_upper == "ERROR"
        return VERBOSITY_ERROR
    elseif verbosity_upper == "WARNING"
        return VERBOSITY_WARNING
    elseif verbosity_upper == "INFO"
        return VERBOSITY_INFO
    elseif verbosity_upper == "DEBUG"
        return VERBOSITY_DEBUG
    else
        return VERBOSITY_INFO  # Default fallback
    end
end

const _VERBOSITY_STRINGS = ("NONE", "ERROR", "WARNING", "INFO", "DEBUG")

function verbosity_enum_to_string(verbosity::Verbosity)::String
    idx = Int(verbosity) + 1
    return idx <= length(_VERBOSITY_STRINGS) ? _VERBOSITY_STRINGS[idx] : "INFO"
end
