# FlatBuffers-to-Julia type mapping and intermediate representation.
#
# FBS_TYPE_MAP resolves field types (byte is signed Int8 per FBS spec).
# ENUM_BASE_TYPE_MAP resolves enum base types (byte is unsigned UInt8, matching OSRM convention).

"""Map from FlatBuffers scalar/string type names to Julia type names."""
const FBS_TYPE_MAP = Dict{String, String}(
    "bool" => "Bool",
    "byte" => "Int8",
    "ubyte" => "UInt8",
    "short" => "Int16",
    "ushort" => "UInt16",
    "int" => "Int32",
    "uint" => "UInt32",
    "int32" => "Int32",
    "uint32" => "UInt32",
    "int64" => "Int64",
    "uint64" => "UInt64",
    "long" => "Int64",
    "ulong" => "UInt64",
    "float" => "Float32",
    "double" => "Float64",
    "string" => "String",
)

"""Map from FlatBuffers enum base type names to Julia type names."""
const ENUM_BASE_TYPE_MAP = Dict{String, String}(
    "byte" => "UInt8",
    "ubyte" => "UInt8",
    "short" => "Int16",
    "ushort" => "UInt16",
    "int" => "Int32",
    "uint" => "UInt32",
)

# --- Intermediate representation for parsed .fbs definitions ---

"""A single value in an enum definition (e.g. `Turn = 0`)."""
struct EnumValueDef
    name::String
    value::Union{Int, Nothing}
end

"""A single field in a struct or table definition."""
struct FieldDef
    name::String
    type::String
    default::Union{String, Nothing}
end

"""A parsed FlatBuffers enum."""
struct EnumDef
    name::String
    base_type::String
    values::Vector{EnumValueDef}
end

"""A parsed FlatBuffers struct (immutable value type)."""
struct StructDef
    name::String
    fields::Vector{FieldDef}
end

"""A parsed FlatBuffers table (mutable reference type)."""
struct TableDef
    name::String
    fields::Vector{FieldDef}
end

"""
    FBSParser(schema_dir::String)

Accumulates parsed definitions from one or more `.fbs` files.
Tracks which file defines each type and include relationships between files.
"""
mutable struct FBSParser
    schema_dir::String
    parsed_files::Set{String}
    enums::Dict{String, EnumDef}
    structs::Dict{String, StructDef}
    tables::Dict{String, TableDef}
    # Track which file defines each type
    enum_files::Dict{String, String}
    struct_files::Dict{String, String}
    table_files::Dict{String, String}
    # Track include relationships
    file_includes::Dict{String, Set{String}}

    FBSParser(schema_dir::String) = new(
        schema_dir,
        Set{String}(),
        Dict{String, EnumDef}(),
        Dict{String, StructDef}(),
        Dict{String, TableDef}(),
        Dict{String, String}(),
        Dict{String, String}(),
        Dict{String, String}(),
        Dict{String, Set{String}}(),
    )
end
