"""Get all files related to a given file (the file itself and all files it includes recursively)."""
function get_related_files(parser::FBSParser, filename::String)::Set{String}
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

"""Extract struct and table dependencies from a type string."""
function extract_type_dependencies(parser::FBSParser, fbs_type)::Set{String}
    dependencies = Set{String}()
    fbs_type = strip(String(fbs_type))

    # Handle arrays: [Type] -> Type
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        inner_type = String(strip(fbs_type[2:(end - 1)]))
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

"""Get all struct and table dependencies for a given struct or table."""
function get_dependencies(def::Union{StructDef, TableDef}, parser::FBSParser)::Set{String}
    dependencies = Set{String}()
    for field in def.fields
        field_type = String(field["type"])
        deps = extract_type_dependencies(parser, field_type)
        union!(dependencies, deps)
    end
    return dependencies
end

"""Generic topological sort using Kahn's algorithm.

Args:
    parser: FBSParser instance
    names: Names to sort
    get_deps_func: Function to get dependencies for a name
    valid_deps: Set of valid dependency names to consider
    in_degree_deps: Set of dependency names that count for in-degree (defaults to valid_deps)
"""
function topological_sort(parser::FBSParser, names::Vector{String}, get_deps_func::Function, valid_deps::Set{String}, in_degree_deps::Set{String} = valid_deps)::Vector{String}
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

"""Topologically sort structs so dependencies come first."""
function topological_sort_structs(parser::FBSParser, struct_names::Vector{String})::Vector{String}
    get_deps = (p, name) -> get_dependencies(p.structs[name], p)
    valid_deps = Set(struct_names)
    return topological_sort(parser, struct_names, get_deps, valid_deps)
end

"""Topologically sort tables so dependencies (structs and other tables) come first."""
function topological_sort_tables(parser::FBSParser, table_names::Vector{String}, struct_names::Vector{String})::Vector{String}
    get_deps = (p, name) -> get_dependencies(p.tables[name], p)
    valid_deps = union(Set(struct_names), Set(table_names))
    table_set = Set(table_names)
    # Only count table dependencies for in-degree (structs are defined first)
    return topological_sort(parser, table_names, get_deps, valid_deps, table_set)
end
