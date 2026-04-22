"""Resolve a schema filename to its full path, checking schema_dir first."""
function _resolve_filepath(parser::FBSParser, filename::String)::String
    filepath = joinpath(parser.schema_dir, filename)
    if isfile(filepath)
        return filepath
    elseif isfile(filename)
        return filename
    else
        error("Schema file not found: $filename (searched $(parser.schema_dir))")
    end
end

"""Read a schema file and return its content as a string."""
function _read_schema_file(parser::FBSParser, filename::String)::String
    filepath = _resolve_filepath(parser, filename)
    return read(filepath, String)
end

"""
    resolve_type(parser::FBSParser, fbs_type::String) -> String

Convert a FlatBuffers type string to the corresponding Julia type string.
Handles arrays (`[Type]` -> `Vector{Type}`), primitives, and user-defined types.
"""
function resolve_type(parser::FBSParser, fbs_type::AbstractString)::String
    fbs_type = strip(String(fbs_type))

    # Handle arrays: [Type] -> Vector{Type}
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        inner_type = strip(fbs_type[2:(end - 1)])
        return "Vector{$(resolve_type(parser, inner_type))}"
    end

    # Primitive / built-in type
    if haskey(FBS_TYPE_MAP, fbs_type)
        return FBS_TYPE_MAP[fbs_type]
    end

    # User-defined type (enum, struct, or table) — return name as-is
    return fbs_type
end

"""Parse enum values from the body between `{...}`. Returns `EnumDef`."""
function _parse_enum(body::String, name::String, base_type::String)::EnumDef
    values = EnumValueDef[]
    for m in eachmatch(r"(\w+)(?:\s*=\s*(\d+))?", body)
        val_name = String(m.captures[1])
        val_num = m.captures[2] !== nothing ? parse(Int, m.captures[2]) : nothing
        push!(values, EnumValueDef(val_name, val_num))
    end
    return EnumDef(name, base_type, values)
end

"""Parse struct fields from the body between `{...}`. Returns `StructDef`."""
function _parse_struct(body::String, name::String)::StructDef
    fields = FieldDef[]
    for m in eachmatch(r"(\w+):\s*([^;]+);", body)
        field_name = String(m.captures[1])
        field_type = strip(String(m.captures[2]))
        push!(fields, FieldDef(field_name, field_type, nothing))
    end
    return StructDef(name, fields)
end

"""Parse table fields (with optional defaults) from the body between `{...}`. Returns `TableDef`."""
function _parse_table(body::String, name::String)::TableDef
    fields = FieldDef[]
    for m in eachmatch(r"(\w+):\s*([^=;]+)(?:\s*=\s*([^;]+))?;", body)
        field_name = String(m.captures[1])
        field_type = strip(String(m.captures[2]))
        default_value = m.captures[3] !== nothing ? strip(String(m.captures[3])) : nothing
        push!(fields, FieldDef(field_name, field_type, default_value))
    end
    return TableDef(name, fields)
end

"""
    parse_recursive!(parser::FBSParser, filename::String)

Parse a `.fbs` file and all its includes, populating `parser` with the definitions found.
Files that have already been parsed are skipped.
"""
function parse_recursive!(parser::FBSParser, filename::String)
    filepath = _resolve_filepath(parser, filename)

    # Skip already-parsed files
    filepath in parser.parsed_files && return
    push!(parser.parsed_files, filepath)

    content = _read_schema_file(parser, filename)

    # Track and recurse into includes
    includes = Set{String}()
    for m in eachmatch(r"include\s+\"([^\"]+)\";", content)
        include_file = String(m.captures[1])
        push!(includes, include_file)
        parse_recursive!(parser, include_file)
    end
    parser.file_includes[filename] = includes

    # Parse enums — capture name, optional base type, and body
    for m in eachmatch(r"enum\s+(\w+)(?::\s*(\w+))?\s*\{(.*?)\}"s, content)
        enum_name = String(m.captures[1])
        base_type = m.captures[2] !== nothing ? String(m.captures[2]) : "byte"
        enum_body = String(m.captures[3])
        parser.enums[enum_name] = _parse_enum(enum_body, enum_name, base_type)
        parser.enum_files[enum_name] = filename
    end

    # Parse structs
    for m in eachmatch(r"struct\s+(\w+)\s*\{(.*?)\}"s, content)
        struct_name = String(m.captures[1])
        parser.structs[struct_name] = _parse_struct(String(m.captures[2]), struct_name)
        parser.struct_files[struct_name] = filename
    end

    # Parse tables
    for m in eachmatch(r"table\s+(\w+)\s*\{(.*?)\}"s, content)
        table_name = String(m.captures[1])
        parser.tables[table_name] = _parse_table(String(m.captures[2]), table_name)
        parser.table_files[table_name] = filename
    end

    return nothing
end

"""Parse all `.fbs` files in the parser's schema directory."""
function parse_all!(parser::FBSParser)
    for filename in filter(f -> endswith(f, ".fbs"), readdir(parser.schema_dir; join = false))
        parse_recursive!(parser, filename)
    end
    return nothing
end
