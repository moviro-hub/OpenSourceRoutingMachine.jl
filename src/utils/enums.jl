using EnumX

"""
    normalize_enum(value, ::Type{T}) -> T

Coerce integers, symbols, or strings into the strongly typed `EnumX` wrapper
while keeping existing enum instances unchanged.
"""
function normalize_enum(value, ::Type{T}) where {T}
    if value isa T
        return value
    elseif value isa Integer
        return T(value)
    elseif value isa Symbol
        return EnumX.byname(T, value; case = :lower)
    elseif value isa AbstractString
        return EnumX.byname(T, Symbol(value); case = :lower)
    else
        throw(ArgumentError("Unsupported $(T) value: $value"))
    end
end

"""
    to_cint(value, enum_type::Type) -> Cint

Normalize a value to the provided enum type and convert the stored ordinal
into a `Cint` for FFI calls.
"""
to_cint(value, ::Type{T}) where {T} = Cint(normalize_enum(value, T))

"""
    to_cint(value, enum_module::Module) -> Cint

Convenience overload that accepts `EnumX.@enumx` generated modules directly.
"""
function to_cint(value, enum_module::Module)
    isdefined(enum_module, :T) || throw(ArgumentError("Unsupported enum module: $(enum_module)"))
    return to_cint(value, getfield(enum_module, :T))
end
