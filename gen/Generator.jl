module Generator

using Downloads

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

# Download functions
"""
    download_flatbuffers(version::String; base_url::String, subdir::String, files::Vector{String}, output_dir::String) -> Bool

Download FlatBuffer schema files (.fbs) from the OSRM backend GitHub repository
for a specific version. Returns true if all downloads succeeded, false otherwise.

Arguments:
- version: OSRM version tag (e.g., "v6.0.0")
- base_url: Base URL for the GitHub repository (keyword argument)
- subdir: Subdirectory path in the repository (keyword argument)
- files: List of .fbs filenames to download (keyword argument)
- output_dir: Output directory for the downloaded files (keyword argument)
"""
function download_flatbuffers(version::String; base_url::String, subdir::String, files::Vector{String}, output_dir::String)::Bool
    # Create output directory if it doesn't exist
    mkpath(output_dir)

    # Download each file
    failed_files = String[]
    for file in files
        url = "$base_url/$version/$subdir/$file"
        output_path = joinpath(output_dir, file)

        try
            println("Downloading $file...")
            Downloads.download(url, output_path)
            println("  ✓ Successfully downloaded $file")
        catch e
            println("  ✗ Failed to download $file: $e")
            push!(failed_files, file)
        end
    end

    println()
    if isempty(failed_files)
        println("Successfully downloaded all $(length(files)) FlatBuffer files")
        return true
    else
        println("Warning: Failed to download $(length(failed_files)) file(s):")
        for file in failed_files
            println("  - $file")
        end
        return false
    end
end

# Parsing helper functions
function resolve_filepath(parser::FBSParser, filename::String)::String
    """Resolve file path, trying schema_dir first, then relative path."""
    filepath = joinpath(parser.schema_dir, filename)
    if !isfile(filepath) && isfile(filename)
        filepath = filename
    elseif !isfile(filepath)
        error("Schema file not found: $filename")
    end
    return filepath
end

function parse_file(parser::FBSParser, filename::String)::String
    """Parse a .fbs file and return its content."""
    filepath = resolve_filepath(parser, filename)

    if filepath in parser.parsed_files
        return ""  # Already parsed
    end

    push!(parser.parsed_files, filepath)
    return read(filepath, String)
end

function resolve_type(parser::FBSParser, fbs_type)::String
    """Convert FlatBuffers type to Julia type."""
    fbs_type = String(fbs_type)

    # Handle arrays
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        inner_type = strip(fbs_type[2:end-1])
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

function parse_enum(content::String, name::String)::EnumDef
    """Parse an enum definition."""
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

function parse_struct(content::String, name::String)::StructDef
    """Parse a struct definition."""
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

function parse_table(content::String, name::String)::TableDef
    """Parse a table definition."""
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

function parse_recursive!(parser::FBSParser, filename::String)
    """Recursively parse a file and its includes."""
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
end

function parse_all(parser::FBSParser)
    """Parse all schema files in the directory."""
    files_to_parse = filter(f -> endswith(f, ".fbs"), readdir(parser.schema_dir; join=false))

    # Parse all files to build complete type registry
    for filename in files_to_parse
        parse_recursive!(parser, filename)
    end
end

function get_related_files(parser::FBSParser, filename::String)::Set{String}
    """Get all files related to a given file (the file itself and all files it includes recursively)."""
    related = Set{String}([filename])
    to_process = [filename]

    while !isempty(to_process)
        current = pop!(to_process)
        if haskey(parser.file_includes, current)
            for included_file in parser.file_includes[current]
                if !(included_file in related)
                    push!(related, included_file)
                    push!(to_process, included_file)
                end
            end
        end
    end

    return related
end

function extract_type_dependencies(parser::FBSParser, fbs_type)::Set{String}
    """Extract struct and table dependencies from a type string."""
    dependencies = Set{String}()
    fbs_type = strip(String(fbs_type))

    # Handle arrays: [Type] -> Type
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        inner_type = String(strip(fbs_type[2:end-1]))
        return extract_type_dependencies(parser, inner_type)
    end

    # Check if it's a basic type (no dependency)
    if haskey(TYPE_MAP, fbs_type)
        return dependencies
    end

    # Check if it's a struct dependency
    if haskey(parser.structs, fbs_type)
        push!(dependencies, fbs_type)
    end

    # Check if it's a table dependency
    if haskey(parser.tables, fbs_type)
        push!(dependencies, fbs_type)
    end

    return dependencies
end

function get_dependencies(def::Union{StructDef, TableDef}, parser::FBSParser)::Set{String}
    """Get all struct and table dependencies for a given struct or table."""
    dependencies = Set{String}()
    for field in def.fields
        field_type = String(field["type"])
        deps = extract_type_dependencies(parser, field_type)
        union!(dependencies, deps)
    end
    return dependencies
end

function topological_sort(parser::FBSParser, names::Vector{String}, get_deps_func::Function, valid_deps::Set{String}, in_degree_deps::Set{String}=valid_deps)::Vector{String}
    """Generic topological sort using Kahn's algorithm.

    Args:
        parser: FBSParser instance
        names: Names to sort
        get_deps_func: Function to get dependencies for a name
        valid_deps: Set of valid dependency names to consider
        in_degree_deps: Set of dependency names that count for in-degree (defaults to valid_deps)
    """
    # Build dependency graph
    graph = Dict{String, Set{String}}()
    for name in names
        deps = get_deps_func(parser, name)
        filtered_deps = Set{String}()
        for dep in deps
            if dep in valid_deps && dep != name
                push!(filtered_deps, dep)
            end
        end
        graph[name] = filtered_deps
    end

    # Calculate in-degrees (only counting dependencies in in_degree_deps)
    in_degree = Dict{String, Int}()
    for name in names
        in_degree[name] = length(filter(d -> d in in_degree_deps, graph[name]))
    end

    # Start with nodes that have no dependencies
    queue = String[name for name in names if in_degree[name] == 0]

    result = String[]
    while !isempty(queue)
        current = popfirst!(queue)
        push!(result, current)

        # Decrease in-degree for nodes that depend on current (only if current counts for in-degree)
        if current in in_degree_deps
            for (name, deps) in graph
                if current in deps && name != current
                    in_degree[name] -= 1
                    if in_degree[name] == 0 && name ∉ result
                        push!(queue, name)
                    end
                end
            end
        end
    end

    # Add any remaining nodes (handles cycles gracefully)
    for name in names
        if name ∉ result
            push!(result, name)
        end
    end

    return result
end

function topological_sort_structs(parser::FBSParser, struct_names::Vector{String})::Vector{String}
    """Topologically sort structs so dependencies come first."""
    get_deps = (p, name) -> get_dependencies(p.structs[name], p)
    valid_deps = Set(struct_names)
    return topological_sort(parser, struct_names, get_deps, valid_deps)
end

function topological_sort_tables(parser::FBSParser, table_names::Vector{String}, struct_names::Vector{String})::Vector{String}
    """Topologically sort tables so dependencies (structs and other tables) come first."""
    get_deps = (p, name) -> get_dependencies(p.tables[name], p)
    valid_deps = union(Set(struct_names), Set(table_names))
    table_set = Set(table_names)
    # Only count table dependencies for in-degree (structs are defined first)
    return topological_sort(parser, table_names, get_deps, valid_deps, table_set)
end

const BASE_TYPE_MAP = Dict(
    "byte" => "UInt8",
    "ubyte" => "UInt8",
    "short" => "Int16",
    "ushort" => "UInt16",
    "int" => "Int32",
    "uint" => "UInt32",
)

function generate_enum_code(parser::FBSParser, enum_name::String, lines::Vector{String})
    """Generate code for a single enum."""
    enum_def = parser.enums[enum_name]
    cenum_type = get(BASE_TYPE_MAP, enum_def.base_type, "UInt8")

    push!(lines, "@cenum($enum_name::$cenum_type, begin")
    current_value = 0
    for val in enum_def.values
        val_name = val["name"]
        val_value = val["value"]
        if val_value !== nothing
            current_value = parse(Int, val_value)
        end
        push!(lines, "    $(enum_name)_$val_name = $current_value")
        current_value += 1
    end
    push!(lines, "end)")
    push!(lines, "")
end

function generate_struct_code(parser::FBSParser, struct_name::String, lines::Vector{String})
    """Generate code for a single struct."""
    struct_def = parser.structs[struct_name]
    push!(lines, "FlatBuffers.@STRUCT struct $struct_name")
    for field in struct_def.fields
        field_type = String(field["type"])
        julia_type = resolve_type(parser, field_type)
        field_name = String(field["name"])
        push!(lines, "    $field_name::$julia_type")
    end
    push!(lines, "end")
    push!(lines, "")
end

function generate_table_code(parser::FBSParser, table_name::String, lines::Vector{String})
    """Generate code for a single table."""
    table_def = parser.tables[table_name]
    push!(lines, "FlatBuffers.@with_kw mutable struct $table_name")
    for field in table_def.fields
        field_type = String(field["type"])
        julia_type = resolve_type(parser, field_type)
        field_name = String(field["name"])

        if field["default"] !== nothing
            default_val = String(field["default"])
            push!(lines, "    $field_name::$julia_type = $default_val")
        elseif startswith(julia_type, "Vector{")
            push!(lines, "    $field_name::$julia_type = []")
        else
            push!(lines, "    $field_name::Union{$julia_type, Nothing} = nothing")
        end
    end
    push!(lines, "end")
    push!(lines, "")
end

function generate_code(parser::FBSParser, target_files::Set{String})::String
    """Generate Julia code from parsed definitions, including only types from target_files."""
    lines = String[]
    push!(lines, "# Auto-generated Julia code from FlatBuffers schema files")
    push!(lines, "# DO NOT EDIT MANUALLY - Generated by Generator.jl")
    push!(lines, "")
    push!(lines, "using FlatBuffers")
    push!(lines, "using CEnum")
    push!(lines, "")

    # Generate enums
    enum_names = [name for (name, file) in parser.enum_files if file in target_files]
    if !isempty(enum_names)
        push!(lines, "# Enums")
        for enum_name in sort(enum_names)
            generate_enum_code(parser, enum_name, lines)
        end
    end

    # Generate structs
    struct_names = [name for (name, file) in parser.struct_files if file in target_files]
    if !isempty(struct_names)
        push!(lines, "# Structs (immutable value types)")
        for struct_name in topological_sort_structs(parser, struct_names)
            generate_struct_code(parser, struct_name, lines)
        end
    end

    # Generate tables
    table_names = [name for (name, file) in parser.table_files if file in target_files]
    if !isempty(table_names)
        push!(lines, "# Tables (mutable reference types)")
        for table_name in topological_sort_tables(parser, table_names, struct_names)
            generate_table_code(parser, table_name, lines)
        end
    end

    return join(lines, "\n")
end

"""
    generate_julia_code(input_file::String, output_file::String) -> Bool

Generate Julia code from FlatBuffers schema files. Processes input_file and all its includes.
Returns true if generation succeeded, false otherwise.

Arguments:
- input_file: Full path to the root .fbs file to process (e.g., "/path/to/fbresult.fbs")
- output_file: Full path to the output Julia file (e.g., "/path/to/output.jl")
"""
function generate_julia_code(input_file::String, output_file::String)::Bool
    # Extract schema directory from input file path
    schema_dir = dirname(input_file)
    input_filename = basename(input_file)

    # Ensure output directory exists
    output_dir = dirname(output_file)
    mkpath(output_dir)

    if !isdir(schema_dir)
        println("Error: Schema directory not found: $schema_dir")
        return false
    end

    if !isfile(input_file)
        println("Error: Input file not found: $input_file")
        return false
    end

    println("Processing FlatBuffer schema file: $input_filename")
    println("Input file: $input_file")
    println("Output file: $output_file")
    println()

    # Parse all files to build complete type registry (needed for includes)
    parser = FBSParser(schema_dir)
    parse_all(parser)

    println("Found $(length(parser.enums)) enums, $(length(parser.structs)) structs, $(length(parser.tables)) tables")
    println()

    # Get all related files (input_filename and its includes)
    # Note: get_related_files expects filename relative to schema_dir
    related_files = get_related_files(parser, input_filename)

    # Generate code for input_file and all its dependencies
    code = generate_code(parser, related_files)

    # Write output file
    write(output_file, code)
    println("Generated: $output_file")
    println()
    println("Successfully generated $(basename(output_file))")
    return true
end

end # module Generator
