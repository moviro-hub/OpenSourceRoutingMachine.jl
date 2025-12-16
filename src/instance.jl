"""
    OSRMConfig(base_path::Union{String, Nothing})

Low-level configuration handle for OSRM.

When `base_path` is `nothing`, uses shared memory mode (via osrm-datastore).
"""
mutable struct OSRMConfig
    ptr::Ptr{Cvoid}

    function OSRMConfig(base_path::Union{String, Nothing})
        ptr = with_error() do error_ptr
            ccall((:osrmc_config_construct, libosrmc), Ptr{Cvoid}, (Cstring, Ptr{Ptr{Cvoid}}), as_cstring_or_null(base_path), error_pointer(error_ptr))
        end

        config = new(ptr)
        finalizer(config) do c
            if c.ptr != C_NULL
                ccall((:osrmc_config_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), c.ptr)
                c.ptr = C_NULL
            end
        end
        if base_path !== nothing
            dir = dirname(base_path)
            base_name = basename(base_path)
            files = readdir(dir)
            if Base.any(f -> startswith(f, base_name) && occursin(r"\.partition", f), files)
                set_algorithm!(config, ALGORITHM_MLD)
            elseif Base.any(f -> startswith(f, base_name) && occursin(r"\.hsgr", f), files)
                set_algorithm!(config, ALGORITHM_CH)
            else
                error("Could not determine algorithm from dataset files in $base_path, are you sure this is a valid OSRM dataset?")
            end
        end
        return config
    end
end

"""
    OSRM(base_path::Union{String, Nothing})

High-level handle for querying an OSRM dataset.

When `base_path` is `nothing`, uses shared memory mode (via osrm-datastore).
"""
mutable struct OSRM
    ptr::Ptr{Cvoid}
    config::OSRMConfig

    function OSRM(config::OSRMConfig)
        ptr = with_error() do error_ptr
            ccall((:osrmc_osrm_construct, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), config.ptr, error_pointer(error_ptr))
        end

        osrm = new(ptr, config)
        finalizer(osrm) do o
            if o.ptr != C_NULL
                ccall((:osrmc_osrm_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), o.ptr)
                o.ptr = C_NULL
            end
        end
        return osrm
    end
end
OSRM(base_path::Union{String, Nothing}) = OSRM(OSRMConfig(base_path))

"""
    set_algorithm!(config::OSRMConfig, algorithm::Algorithm)

Set routing algorithm.
"""
function set_algorithm!(config::OSRMConfig, algorithm::Algorithm)
    code = Cint(algorithm)
    with_error() do error_ptr
        ccall((:osrmc_config_set_algorithm, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, code, error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_algorithm!(osrm::OSRM, algorithm) = set_algorithm!(osrm.config, algorithm)

"""
    get_algorithm(config::OSRMConfig) -> Algorithm

Get routing algorithm.
"""
function get_algorithm(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_algorithm, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Algorithm(out_value[])
end
get_algorithm(osrm::OSRM) = get_algorithm(osrm.config)

"""
    set_max_locations_trip!(config::OSRMConfig, max_locations)

Set maximum number of locations for Trip queries.
"""
function set_max_locations_trip!(config::OSRMConfig, max_locations::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_locations_trip, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_locations), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_locations_trip!(osrm::OSRM, max_locations::Integer) = set_max_locations_trip!(osrm.config, max_locations)

"""
    get_max_locations_trip(config::OSRMConfig) -> Int

Get maximum number of locations for Trip queries.
"""
function get_max_locations_trip(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_locations_trip, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_locations_trip(osrm::OSRM) = get_max_locations_trip(osrm.config)

"""
    set_max_locations_viaroute!(config::OSRMConfig, max_locations)

Set maximum number of locations for Route queries.
"""
function set_max_locations_viaroute!(config::OSRMConfig, max_locations::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_locations_viaroute, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_locations), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_locations_viaroute!(osrm::OSRM, max_locations::Integer) = set_max_locations_viaroute!(osrm.config, max_locations)

"""
    get_max_locations_viaroute(config::OSRMConfig) -> Int

Get maximum number of locations for Route queries.
"""
function get_max_locations_viaroute(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_locations_viaroute, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_locations_viaroute(osrm::OSRM) = get_max_locations_viaroute(osrm.config)

"""
    set_max_locations_distance_table!(config::OSRMConfig, max_locations)

Set maximum number of locations for Table queries.
"""
function set_max_locations_distance_table!(config::OSRMConfig, max_locations::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_locations_distance_table, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_locations), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_locations_distance_table!(osrm::OSRM, max_locations::Integer) = set_max_locations_distance_table!(osrm.config, max_locations)

"""
    get_max_locations_distance_table(config::OSRMConfig) -> Int

Get maximum number of locations for Table queries.
"""
function get_max_locations_distance_table(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_locations_distance_table, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_locations_distance_table(osrm::OSRM) = get_max_locations_distance_table(osrm.config)

"""
    set_max_locations_map_matching!(config::OSRMConfig, max_locations)

Set maximum number of coordinates for Map Matching queries.
"""
function set_max_locations_map_matching!(config::OSRMConfig, max_locations::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_locations_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_locations), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_locations_map_matching!(osrm::OSRM, max_locations::Integer) = set_max_locations_map_matching!(osrm.config, max_locations)

"""
    get_max_locations_map_matching(config::OSRMConfig) -> Int

Get maximum number of coordinates for Map Matching queries.
"""
function get_max_locations_map_matching(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_locations_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_locations_map_matching(osrm::OSRM) = get_max_locations_map_matching(osrm.config)

"""
    set_max_radius_map_matching!(config::OSRMConfig, radius)

Set maximum search radius for Map Matching queries.
"""
function set_max_radius_map_matching!(config::OSRMConfig, radius::Real)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_radius_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), config.ptr, Cdouble(radius), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_radius_map_matching!(osrm::OSRM, radius::Real) = set_max_radius_map_matching!(osrm.config, radius)

"""
    get_max_radius_map_matching(config::OSRMConfig) -> Float64

Get maximum search radius for Map Matching queries.
"""
function get_max_radius_map_matching(config::OSRMConfig)
    out_value = Ref{Cdouble}(0.0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_radius_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cdouble}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Float64(out_value[])
end
get_max_radius_map_matching(osrm::OSRM) = get_max_radius_map_matching(osrm.config)

"""
    set_max_results_nearest!(config::OSRMConfig, max_results)

Set maximum number of results for Nearest queries.
"""
function set_max_results_nearest!(config::OSRMConfig, max_results::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_results_nearest, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_results), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_results_nearest!(osrm::OSRM, max_results::Integer) = set_max_results_nearest!(osrm.config, max_results)

"""
    get_max_results_nearest(config::OSRMConfig) -> Int

Get maximum number of results for Nearest queries.
"""
function get_max_results_nearest(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_results_nearest, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_results_nearest(osrm::OSRM) = get_max_results_nearest(osrm.config)

"""
    set_default_radius!(config::OSRMConfig, radius)

Set default snapping radius.
"""
function set_default_radius!(config::OSRMConfig, radius::Real)
    with_error() do error_ptr
        ccall((:osrmc_config_set_default_radius, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), config.ptr, Cdouble(radius), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_default_radius!(osrm::OSRM, radius::Real) = set_default_radius!(osrm.config, radius)

"""
    get_default_radius(config::OSRMConfig) -> Float64

Get default snapping radius.
"""
function get_default_radius(config::OSRMConfig)
    out_value = Ref{Cdouble}(0.0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_default_radius, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cdouble}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Float64(out_value[])
end
get_default_radius(osrm::OSRM) = get_default_radius(osrm.config)

"""
    set_max_alternatives!(config::OSRMConfig, max_alternatives)

Set maximum number of route alternatives.
"""
function set_max_alternatives!(config::OSRMConfig, max_alternatives::Integer)
    with_error() do error_ptr
        ccall((:osrmc_config_set_max_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config.ptr, Cint(max_alternatives), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_max_alternatives!(osrm::OSRM, max_alternatives::Integer) = set_max_alternatives!(osrm.config, max_alternatives)

"""
    get_max_alternatives(config::OSRMConfig) -> Int

Get maximum number of route alternatives.
"""
function get_max_alternatives(config::OSRMConfig)
    out_value = Ref{Cint}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_max_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cint}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return Int(out_value[])
end
get_max_alternatives(osrm::OSRM) = get_max_alternatives(osrm.config)

"""
    set_use_mmap!(config::OSRMConfig, use_mmap)

Enable or disable memory-mapping datasets.
"""
function set_use_mmap!(config::OSRMConfig, use_mmap::Bool)
    with_error() do error_ptr
        ccall((:osrmc_config_set_use_mmap, libosrmc), Cvoid, (Ptr{Cvoid}, Bool, Ptr{Ptr{Cvoid}}), config.ptr, use_mmap, error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_use_mmap!(osrm::OSRM, use_mmap::Bool) = set_use_mmap!(osrm.config, use_mmap)

"""
    get_use_mmap(config::OSRMConfig) -> Bool

Get whether memory-mapping is enabled.
"""
function get_use_mmap(config::OSRMConfig)
    out_value = Ref{Bool}(false)
    with_error() do error_ptr
        ccall((:osrmc_config_get_use_mmap, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Bool}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return out_value[]
end
get_use_mmap(osrm::OSRM) = get_use_mmap(osrm.config)

"""
    set_use_shared_memory!(config::OSRMConfig, use_shared_memory)

Enable or disable shared memory mode.
"""
function set_use_shared_memory!(config::OSRMConfig, use_shm::Bool)
    with_error() do error_ptr
        ccall((:osrmc_config_set_use_shared_memory, libosrmc), Cvoid, (Ptr{Cvoid}, Bool, Ptr{Ptr{Cvoid}}), config.ptr, use_shm, error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_use_shared_memory!(osrm::OSRM, use_shm::Bool) = set_use_shared_memory!(osrm.config, use_shm)

"""
    get_use_shared_memory(config::OSRMConfig) -> Bool

Get whether shared memory mode is enabled.
"""
function get_use_shared_memory(config::OSRMConfig)
    out_value = Ref{Bool}(false)
    with_error() do error_ptr
        ccall((:osrmc_config_get_use_shared_memory, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Bool}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    return out_value[]
end
get_use_shared_memory(osrm::OSRM) = get_use_shared_memory(osrm.config)

"""
    set_dataset_name!(config::OSRMConfig, dataset_name)

Set dataset name for shared memory mode (or `nothing` to clear).
"""
function set_dataset_name!(config::OSRMConfig, dataset_name::Union{AbstractString, Nothing})
    with_error() do error_ptr
        ccall((:osrmc_config_set_dataset_name, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, as_cstring_or_null(dataset_name), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_dataset_name!(osrm::OSRM, dataset_name::Union{AbstractString, Nothing}) = set_dataset_name!(osrm.config, dataset_name)

"""
    get_dataset_name(config::OSRMConfig) -> Union{String, Nothing}

Get dataset name for shared memory mode (or `nothing` if not set).
"""
function get_dataset_name(config::OSRMConfig)
    out_value = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall((:osrmc_config_get_dataset_name, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cstring}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    ptr = out_value[]
    return ptr == C_NULL ? nothing : unsafe_string(ptr)
end
get_dataset_name(osrm::OSRM) = get_dataset_name(osrm.config)

"""
    set_memory_file!(config::OSRMConfig, memory_file)

Set memory file path (or `nothing` to clear).
"""
function set_memory_file!(config::OSRMConfig, memory_file::Union{AbstractString, Nothing})
    with_error() do error_ptr
        ccall((:osrmc_config_set_memory_file, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, as_cstring_or_null(memory_file), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_memory_file!(osrm::OSRM, memory_file::Union{AbstractString, Nothing}) = set_memory_file!(osrm.config, memory_file)

"""
    get_memory_file(config::OSRMConfig) -> Union{String, Nothing}

Get memory file path (or `nothing` if not set).
"""
function get_memory_file(config::OSRMConfig)
    out_value = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall((:osrmc_config_get_memory_file, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cstring}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    ptr = out_value[]
    return ptr == C_NULL ? nothing : unsafe_string(ptr)
end
get_memory_file(osrm::OSRM) = get_memory_file(osrm.config)

"""
    set_verbosity!(config::OSRMConfig, verbosity)

Set logging verbosity level (or `nothing` to clear).
"""
function set_verbosity!(config::OSRMConfig, verbosity::Union{Verbosity, Nothing})
    verbosity_str = verbosity === nothing ? nothing : verbosity_enum_to_string(verbosity)
    with_error() do error_ptr
        ccall((:osrmc_config_set_verbosity, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, as_cstring_or_null(verbosity_str), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_verbosity!(osrm::OSRM, verbosity::Union{Verbosity, Nothing}) = set_verbosity!(osrm.config, verbosity)

"""
    get_verbosity(config::OSRMConfig) -> Union{Verbosity, Nothing}

Get logging verbosity level (or `nothing` if not set).
"""
function get_verbosity(config::OSRMConfig)
    out_value = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall((:osrmc_config_get_verbosity, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Cstring}, Ptr{Ptr{Cvoid}}), config.ptr, out_value, error_pointer(error_ptr))
        nothing
    end
    ptr = out_value[]
    if ptr == C_NULL
        return nothing
    end
    verbosity_str = uppercase(unsafe_string(ptr))
    # Convert string back to enum
    return verbosity_string_to_enum(verbosity_str)
end
get_verbosity(osrm::OSRM) = get_verbosity(osrm.config)

"""
    disable_feature_dataset!(config::OSRMConfig, dataset_name)

Disable a feature dataset by name.
"""
function disable_feature_dataset!(config::OSRMConfig, dataset_name::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_config_disable_feature_dataset, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, Base.unsafe_convert(Cstring, Base.cconvert(Cstring, dataset_name)), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
disable_feature_dataset!(osrm::OSRM, dataset_name::AbstractString) = disable_feature_dataset!(osrm.config, dataset_name)

"""
    get_disabled_feature_dataset_count(config::OSRMConfig) -> Int

Get number of disabled feature datasets.
"""
function get_disabled_feature_dataset_count(config::OSRMConfig)
    out_count = Ref{Csize_t}(0)
    with_error() do error_ptr
        ccall((:osrmc_config_get_disabled_feature_dataset_count, libosrmc), Cvoid, (Ptr{Cvoid}, Ref{Csize_t}, Ptr{Ptr{Cvoid}}), config.ptr, out_count, error_pointer(error_ptr))
        nothing
    end
    return Int(out_count[])
end
get_disabled_feature_dataset_count(osrm::OSRM) = get_disabled_feature_dataset_count(osrm.config)

"""
    get_disabled_feature_dataset_at(config::OSRMConfig, index) -> String

Get name of disabled feature dataset at index.
"""
function get_disabled_feature_dataset_at(config::OSRMConfig, index::Integer)
    out_dataset_name = Ref{Cstring}(C_NULL)
    with_error() do error_ptr
        ccall((:osrmc_config_get_disabled_feature_dataset_at, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ref{Cstring}, Ptr{Ptr{Cvoid}}), config.ptr, Csize_t(index), out_dataset_name, error_pointer(error_ptr))
        nothing
    end
    ptr = out_dataset_name[]
    ptr == C_NULL && error("Disabled feature dataset at index $index returned NULL")
    return unsafe_string(ptr)
end
get_disabled_feature_dataset_at(osrm::OSRM, index::Integer) = get_disabled_feature_dataset_at(osrm.config, index)

"""
    clear_disabled_feature_datasets!(config::OSRMConfig)

Clear all disabled feature datasets.
"""
function clear_disabled_feature_datasets!(config::OSRMConfig)
    with_error() do error_ptr
        ccall((:osrmc_config_clear_disabled_feature_datasets, libosrmc), Cvoid, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), config.ptr, error_pointer(error_ptr))
        nothing
    end
    return nothing
end
clear_disabled_feature_datasets!(osrm::OSRM) = clear_disabled_feature_datasets!(osrm.config)
