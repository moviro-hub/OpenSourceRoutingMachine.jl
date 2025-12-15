# Parsing helper functions
"""Resolve file path, trying schema_dir first, then relative path."""
function resolve_filepath(parser::FBSParser, filename::String)::String
    filepath = joinpath(parser.schema_dir, filename)
    if !isfile(filepath) && isfile(filename)
        filepath = filename
    elseif !isfile(filepath)
        error("Schema file not found: $filename")
    end
    return filepath
end

"""Parse a .fbs file and return its content."""
function parse_file(parser::FBSParser, filename::String)::String
    filepath = resolve_filepath(parser, filename)

    if filepath in parser.parsed_files
        return ""  # Already parsed
    end

    push!(parser.parsed_files, filepath)
    return read(filepath, String)
end

"""Convert FlatBuffers type to Julia type."""
function resolve_type(parser::FBSParser, fbs_type)::String
    fbs_type = String(fbs_type)

    # Handle arrays
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        inner_type = strip(fbs_type[2:(end - 1)])
        return "Vector{$(resolve_type(parser, inner_type))}"
    end

    fbs_type = strip(fbs_type)

    # Handle basic types
    if haskey(TYPE_MAP, fbs_type)
        return TYPE_MAP[fbs_type]
    end

    # Handle enums, structs, and tables (return the name)
    if haskey(parser.enums, fbs_type) || haskey(parser.structs, fbs_type) || haskey(parser.tables, fbs_type)
        return fbs_type
    end

    # Default: assume it's a user-defined type
    return fbs_type
end

"""Parse an enum definition."""
function parse_enum(content::String, name::String)::EnumDef
    # Extract base type
    base_type_match = match(r"enum\s+\w+:\s*(\w+)", content)
    base_type = base_type_match !== nothing ? String(base_type_match.captures[1]) : "byte"

    # Extract values
    values = Dict{String, Union{String, Nothing}}[]
    value_pattern = r"(\w+)(?:\s*=\s*(\d+))?"
    for match in eachmatch(value_pattern, content)
        val_name = String(match.captures[1])
        val_num = length(match.captures) > 1 && match.captures[2] !== nothing ? String(match.captures[2]) : nothing
        push!(values, Dict("name" => val_name, "value" => val_num))
    end

    return EnumDef(name, base_type, values)
end

"""Parse a struct definition."""
function parse_struct(content::String, name::String)::StructDef
    fields = Dict{String, Union{String, Nothing}}[]
    # Match field definitions: name: type;
    field_pattern = r"(\w+):\s*([^;]+);"
    for match in eachmatch(field_pattern, content)
        field_name = String(match.captures[1])
        field_type = strip(String(match.captures[2]))
        push!(fields, Dict("name" => field_name, "type" => field_type, "default" => nothing))
    end

    return StructDef(name, fields)
end

"""Parse a table definition."""
function parse_table(content::String, name::String)::TableDef
    fields = Dict{String, Union{String, Nothing}}[]
    # Match field definitions: name: type [= default];
    field_pattern = r"(\w+):\s*([^=;]+)(?:\s*=\s*([^;]+))?;"
    for match in eachmatch(field_pattern, content)
        field_name = String(match.captures[1])
        field_type = strip(String(match.captures[2]))
        default_value = length(match.captures) > 2 && match.captures[3] !== nothing ? strip(String(match.captures[3])) : nothing
        push!(fields, Dict("name" => field_name, "type" => field_type, "default" => default_value))
    end

    return TableDef(name, fields)
end

"""Recursively parse a file and its includes."""
function parse_recursive!(parser::FBSParser, filename::String)
    filepath = resolve_filepath(parser, filename)

    if filepath in parser.parsed_files
        return
    end

    content = parse_file(parser, filename)
    if isempty(content)
        return
    end

    # Parse namespace
    ns_match = match(r"namespace\s+([\w.]+);", content)
    if ns_match !== nothing
        parser.namespace = String(ns_match.captures[1])
    end

    # Track includes for this file
    includes = Set{String}()
    include_pattern = r"include\s+\"([^\"]+)\";"
    for match in eachmatch(include_pattern, content)
        include_file = String(match.captures[1])
        push!(includes, include_file)
        parse_recursive!(parser, include_file)
    end
    parser.file_includes[filename] = includes

    # Parse enums
    enum_pattern = r"enum\s+(\w+)(?::\s*(\w+))?\s*\{(.*?)\}"s
    for match in eachmatch(enum_pattern, content)
        enum_name = String(match.captures[1])
        enum_content = String(match.captures[3])
        parser.enums[enum_name] = parse_enum(enum_content, enum_name)
        parser.enum_files[enum_name] = filename
    end

    # Parse structs
    struct_pattern = r"struct\s+(\w+)\s*\{(.*?)\}"s
    for match in eachmatch(struct_pattern, content)
        struct_name = String(match.captures[1])
        struct_content = String(match.captures[2])
        parser.structs[struct_name] = parse_struct(struct_content, struct_name)
        parser.struct_files[struct_name] = filename
    end

    # Parse tables
    table_pattern = r"table\s+(\w+)\s*\{(.*?)\}"s
    for match in eachmatch(table_pattern, content)
        table_name = String(match.captures[1])
        table_content = String(match.captures[2])
        parser.tables[table_name] = parse_table(table_content, table_name)
        parser.table_files[table_name] = filename
    end
    return
end

"""Parse all schema files in the directory."""
function parse_all(parser::FBSParser)
    files_to_parse = filter(f -> endswith(f, ".fbs"), readdir(parser.schema_dir; join = false))

    # Parse all files to build complete type registry
    for filename in files_to_parse
        parse_recursive!(parser, filename)
    end
    return
end
