# Type mapping from FlatBuffers to Julia
const TYPE_MAP = Dict(
    "bool" => "Bool",
    "byte" => "Int8",
    "ubyte" => "UInt8",
    "short" => "Int16",
    "ushort" => "UInt16",
    "int" => "Int32",
    "uint" => "UInt32",
    "uint32" => "UInt32",
    "uint64" => "UInt64",
    "int32" => "Int32",
    "int64" => "Int64",
    "long" => "Int64",
    "ulong" => "UInt64",
    "float" => "Float32",
    "double" => "Float64",
    "string" => "String",
)

# Data structures for parsing
mutable struct EnumDef
    name::String
    base_type::String
    values::Vector{Dict{String, Union{String, Nothing}}}
end

mutable struct StructDef
    name::String
    fields::Vector{Dict{String, Union{String, Nothing}}}
end

mutable struct TableDef
    name::String
    fields::Vector{Dict{String, Union{String, Nothing}}}
end

mutable struct FBSParser
    schema_dir::String
    parsed_files::Set{String}
    enums::Dict{String, EnumDef}
    structs::Dict{String, StructDef}
    tables::Dict{String, TableDef}
    namespace::Union{String, Nothing}
    # Track which file defines each type
    enum_files::Dict{String, String}  # enum_name -> filename
    struct_files::Dict{String, String}  # struct_name -> filename
    table_files::Dict{String, String}  # table_name -> filename
    # Track include relationships
    file_includes::Dict{String, Set{String}}  # filename -> Set of included filenames

    FBSParser(schema_dir::String) = new(
        schema_dir,
        Set{String}(),
        Dict{String, EnumDef}(),
        Dict{String, StructDef}(),
        Dict{String, TableDef}(),
        nothing,
        Dict{String, String}(),
        Dict{String, String}(),
        Dict{String, String}(),
        Dict{String, Set{String}}()
    )
end

const BASE_TYPE_MAP = Dict(
    "byte" => "UInt8",
    "ubyte" => "UInt8",
    "short" => "Int16",
    "ushort" => "UInt16",
    "int" => "Int32",
    "uint" => "UInt32",
)
