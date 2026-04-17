"""
    get_related_files(parser::FBSParser, filename::String) -> Set{String}

Return `filename` and all files it transitively includes.
"""
function get_related_files(parser::FBSParser, filename::String)::Set{String}
    related = Set{String}([filename])
    queue = [filename]

    while !isempty(queue)
        current = pop!(queue)
        for included in get(parser.file_includes, current, Set{String}())
            if included ∉ related
                push!(related, included)
                push!(queue, included)
            end
        end
    end

    return related
end

"""
    extract_type_dependencies(parser::FBSParser, fbs_type::AbstractString) -> Set{String}

Return the set of user-defined struct/table names that `fbs_type` depends on.
Primitive types and enums are not considered dependencies (they have no ordering constraints).
"""
function extract_type_dependencies(parser::FBSParser, fbs_type::AbstractString)::Set{String}
    fbs_type = strip(String(fbs_type))
    deps = Set{String}()

    # Unwrap array type: [Type] -> Type
    if startswith(fbs_type, '[') && endswith(fbs_type, ']')
        return extract_type_dependencies(parser, fbs_type[2:(end - 1)])
    end

    # Skip primitives
    haskey(FBS_TYPE_MAP, fbs_type) && return deps

    # Record struct/table dependencies
    if haskey(parser.structs, fbs_type) || haskey(parser.tables, fbs_type)
        push!(deps, fbs_type)
    end

    return deps
end

"""Collect all struct/table dependencies for a struct or table definition."""
function _get_field_dependencies(def::Union{StructDef, TableDef}, parser::FBSParser)::Set{String}
    deps = Set{String}()
    for field in def.fields
        union!(deps, extract_type_dependencies(parser, field.type))
    end
    return deps
end

"""
    topological_sort(names, get_deps; in_degree_names=names) -> Vector{String}

Kahn's algorithm. `get_deps(name)` returns dependency names for `name`.
Only dependencies present in `names` are considered.
`in_degree_names` controls which dependencies count toward in-degree
(e.g. exclude structs when sorting tables, since structs are already emitted).
Warns on cycles and appends remaining nodes in input order.
"""
function topological_sort(
    names::Vector{String},
    get_deps::Function;
    in_degree_names::Set{String} = Set(names),
)::Vector{String}
    name_set = Set(names)

    # Build adjacency: name -> set of dependencies within `names`
    graph = Dict{String, Set{String}}()
    for name in names
        graph[name] = filter(d -> d ∈ name_set && d != name, get_deps(name))
    end

    # In-degree: count only deps in `in_degree_names`
    in_degree = Dict(name => count(d -> d ∈ in_degree_names, graph[name]) for name in names)

    queue = [name for name in names if in_degree[name] == 0]
    result = String[]

    while !isempty(queue)
        current = popfirst!(queue)
        push!(result, current)

        # Only update in-degrees if current is in the counted set
        current ∉ in_degree_names && continue
        for (name, deps) in graph
            if current ∈ deps && name ∉ result
                in_degree[name] -= 1
                if in_degree[name] == 0
                    push!(queue, name)
                end
            end
        end
    end

    # Append any remaining nodes (cycle present)
    remaining = [name for name in names if name ∉ result]
    if !isempty(remaining)
        @warn "Dependency cycle detected among: $(join(remaining, ", ")). Appending in input order."
        append!(result, remaining)
    end

    return result
end

"""Sort struct names so that dependencies come before dependents."""
function topological_sort_structs(parser::FBSParser, struct_names::Vector{String})::Vector{String}
    get_deps = name -> _get_field_dependencies(parser.structs[name], parser)
    return topological_sort(struct_names, get_deps)
end

"""Sort table names so that table-to-table dependencies come before dependents.
Struct dependencies are ignored here because all structs are emitted first."""
function topological_sort_tables(parser::FBSParser, table_names::Vector{String})::Vector{String}
    get_deps = name -> _get_field_dependencies(parser.tables[name], parser)
    return topological_sort(table_names, get_deps)
end
