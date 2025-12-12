"""
    OSRMConfig(base_path::Union{String, Nothing})

Low-level configuration handle for OSRM; most callers will use `OSRM(base_path)`
instead of constructing this directly.

When `base_path` is `nothing`, the config will use shared memory mode (via osrm-datastore).
In this case, you must manually set the algorithm using `set_algorithm!()` before constructing OSRM.
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
                set_algorithm!(config, Algorithm(1))  # mld
            elseif Base.any(f -> startswith(f, base_name) && occursin(r"\.hsgr", f), files)
                set_algorithm!(config, Algorithm(0))  # ch
            else
                error("Could not determine algorithm from dataset files in $base_path, are you sure this is a valid OSRM dataset?")
            end
        end
        return config
    end
end

"""
    OSRM(base_path::Union{String, Nothing})

High-level handle for querying an OSRM dataset located at `base_path`.
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

Force a specific routing algorithm for the given configuration instead of
letting it be inferred from dataset files on disk.
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
    set_max_locations_trip!(config::OSRMConfig, max_locations)

Configure the maximum number of locations OSRM will accept for Trip queries.
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
    set_max_locations_viaroute!(config::OSRMConfig, max_locations)

Configure the maximum number of locations OSRM will accept for Route (viaroute) queries.
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
    set_max_locations_distance_table!(config::OSRMConfig, max_locations)

Configure the maximum number of locations accepted for Table (matrix) queries.
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
    set_max_locations_map_matching!(config::OSRMConfig, max_locations)

Configure how many coordinates OSRM will accept for Map Matching requests.
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
    set_max_radius_map_matching!(config::OSRMConfig, radius)

Set the maximum search radius OSRM will use when snapping points for Map
Matching queries.
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
    set_max_results_nearest!(config::OSRMConfig, max_results)

Limit how many nearest candidates OSRM should return for Nearest queries.
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
    set_default_radius!(config::OSRMConfig, radius)

Set the default snapping radius used when no per-coordinate radius is provided.
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
    set_max_alternatives!(config::OSRMConfig, max_alternatives)

Configure the global upper bound on how many route alternatives OSRM may return.
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
    set_use_mmap!(config::OSRMConfig, use_mmap)

Toggle whether OSRM should memory-map datasets instead of loading them fully
into RAM.
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
    set_use_shared_memory!(config::OSRMConfig, use_shared_memory)

Control whether OSRM should attach to a shared-memory region populated by
`osrm-datastore` for dataset access.
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
    set_dataset_name!(config::OSRMConfig, dataset_name)

Select which named dataset OSRM should attach to when running in shared-memory
mode (or clear it by passing `nothing`).
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
    set_memory_file!(config::OSRMConfig, memory_file)

Set the memory file path for OSRM to use (or clear it by passing `nothing`).
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
    set_verbosity!(config::OSRMConfig, verbosity)

Set the logging verbosity level for OSRM (or clear it by passing `nothing`).
"""
function set_verbosity!(config::OSRMConfig, verbosity::Union{AbstractString, Nothing})
    with_error() do error_ptr
        ccall((:osrmc_config_set_verbosity, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, as_cstring_or_null(verbosity), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
set_verbosity!(osrm::OSRM, verbosity::Union{AbstractString, Nothing}) = set_verbosity!(osrm.config, verbosity)

function disable_feature_dataset!(config::OSRMConfig, dataset_name::AbstractString)
    with_error() do error_ptr
        ccall((:osrmc_config_disable_feature_dataset, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config.ptr, as_cstring(dataset_name), error_pointer(error_ptr))
        nothing
    end
    return nothing
end
disable_feature_dataset!(osrm::OSRM, dataset_name::AbstractString) = disable_feature_dataset!(osrm.config, dataset_name)

function clear_disabled_feature_datasets!(config::OSRMConfig)
    with_error() do error_ptr
        ccall((:osrmc_config_clear_disabled_feature_datasets, libosrmc), Cvoid, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), config.ptr, error_pointer(error_ptr))
        nothing
    end
    return nothing
end
clear_disabled_feature_datasets!(osrm::OSRM) = clear_disabled_feature_datasets!(osrm.config)
