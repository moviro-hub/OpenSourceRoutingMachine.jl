"""
Centralized enum definitions and conversions for libosrmc.
"""
module Enums

using EnumX
using ..CWrapper

export Algorithm, OutputFormat, Snapping, Approach, Profile
export to_cint

@enumx Algorithm::Cint begin
    ch = Cint(0)
    mld = Cint(1)
end # module Enums

@enumx OutputFormat::Cint begin
    json = Cint(0)
    flatbuffers = Cint(1)
end

@enumx Snapping::Cint begin
    default = Cint(0)
    any = Cint(1)
end

@enumx Approach::Cint begin
    curb = Cint(0)
    unrestricted = Cint(1)
    opposite = Cint(2)
end

"""
    Profile

Enumeration of built-in OSRM Lua profiles shipped with the artifact.
"""
@enumx Profile::Cint begin
    car = Cint(0)
    bicycle = Cint(1)
    foot = Cint(2)
end

"""
    normalize_enum(value, ::Type{T}) -> T

Convert integers, symbols, strings, or EnumX values into the concrete enum `T`.
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
    to_cint(value, ::Type{T}) -> Cint

Normalize `value` into enum `T` and return the underlying `Cint`.
"""
to_cint(value, ::Type{T}) where {T} = Cint(normalize_enum(value, T))

function to_cint(value, enum_module::Module)
    isdefined(enum_module, :T) || throw(ArgumentError("Unsupported enum module: $(enum_module)"))
    return to_cint(value, getfield(enum_module, :T))
end

end
