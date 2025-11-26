"""
Configuration and OSRM instance management so higher-level code can own native
libosrm handles safely.
"""
module Config

using ..CWrapper
using ..Error
using ..Enums: Algorithm, to_cint
using Libdl

@inline function _error_ptr(ref::Ref{Ptr{Cvoid}})
    Base.unsafe_convert(Ptr{Ptr{Cvoid}}, ref)
end # module Config

@inline function _call_with_error(f::Function)
    error_ref = Ref{Ptr{Cvoid}}(C_NULL)
    result = f(error_ref)
    Error.check_error(error_ref)
    return result
end

@inline function _cstring(str::AbstractString)
    cstr = Base.cconvert(Cstring, str)
    Base.unsafe_convert(Cstring, cstr)
end

@inline function _cstring_or_null(str::Union{AbstractString,Nothing})
    str === nothing ? C_NULL : _cstring(str)
end

"""
    OSRMConfig

Wraps the libosrm configuration pointer and owns its lifetime, letting callers
set options from Julia without worrying about manual frees.
"""
mutable struct OSRMConfig
    ptr::Ptr{Cvoid}

    function OSRMConfig(base_path::String)
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_config_construct(_cstring(base_path), _error_ptr(error_ptr))
        end

        config = new(ptr)
        finalizer(config) do c
            if c.ptr != C_NULL
                CWrapper.osrmc_config_destruct(c.ptr)
                c.ptr = C_NULL
            end
        end
        # OSRM defaults to CH and doesn't auto-detect, so we detect from files and set it
        if _check_algorithm_symbol_available()
            try
                dir = dirname(base_path)
                base_name = basename(base_path)
                files = readdir(dir)
                if any(f -> startswith(f, base_name) && occursin(r"\.hsgr", f), files)
                    set_algorithm!(config, Algorithm.ch)
                elseif any(f -> startswith(f, base_name) && occursin(r"\.partition", f), files)
                    set_algorithm!(config, Algorithm.mld)
                end
            catch
            end
        end
        return config
    end
end

"""
    OSRM

Holds the libosrm routing instance and its backing config so we can submit
queries directly to the engine.
"""
mutable struct OSRM
    ptr::Ptr{Cvoid}
    # Keep a strong reference so the config isn't GC'd while libosrm still reads it.
    config::OSRMConfig

    function OSRM(config::OSRMConfig)
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_osrm_construct(config.ptr, _error_ptr(error_ptr))
        end

        osrm = new(ptr, config)
        finalizer(osrm) do o
            if o.ptr != C_NULL
                CWrapper.osrmc_osrm_destruct(o.ptr)
                o.ptr = C_NULL
            end
        end
        return osrm
    end
end

"""
    get_version() -> UInt32

Expose libosrmc's build version so applications can log or gate behavior based
on the engine they are linked against.
"""
function get_version()
    CWrapper.osrmc_get_version()
end

"""
    is_abi_compatible() -> Bool

Allows callers to verify that the currently loaded libosrmc matches the Julia
wrapper's expectations before making calls.
"""
function is_abi_compatible()
    CWrapper.osrmc_is_abi_compatible() != 0
end

# Cache the result of symbol availability check
const _algorithm_symbol_available = Ref{Union{Bool,Nothing}}(nothing)

function _check_algorithm_symbol_available()
    if _algorithm_symbol_available[] === nothing
        handle = Libdl.dlopen(CWrapper.libosrmc)
        sym = Libdl.dlsym_e(handle, :osrmc_config_set_algorithm)
        _algorithm_symbol_available[] = (sym != C_NULL)
    end
    return _algorithm_symbol_available[]
end

"""
    set_algorithm!(config::OSRMConfig, algorithm)

Choose between CH and MLD at runtime so deployments can target the graph type
they have prepared on disk.

If the C library doesn't support algorithm selection (symbol not available),
this function will silently return without setting the algorithm. The library
will use its own auto-detection in that case.
"""
function set_algorithm!(config::OSRMConfig, algorithm)
    # Check if symbol exists before trying to call it
    if !_check_algorithm_symbol_available()
        # Symbol doesn't exist, library will use auto-detection
        return config
    end

    code = to_cint(algorithm, Algorithm)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_algorithm(config.ptr, code, _error_ptr(error_ptr))
        nothing
    end
    config
end

"""
    set_max_locations_trip!(config, max_locations)

Ensure libosrm enforces the expected trip limits for your deployment (use -1 to
match osrm-routed's "unlimited" behavior).
"""
function set_max_locations_trip!(config::OSRMConfig, max_locations::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_locations_trip(config.ptr, Cint(max_locations), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_locations_viaroute!(config::OSRMConfig, max_locations::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_locations_viaroute(config.ptr, Cint(max_locations), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_locations_distance_table!(config::OSRMConfig, max_locations::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_locations_distance_table(config.ptr, Cint(max_locations), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_locations_map_matching!(config::OSRMConfig, max_locations::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_locations_map_matching(config.ptr, Cint(max_locations), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_radius_map_matching!(config::OSRMConfig, radius::Real)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_radius_map_matching(config.ptr, Cdouble(radius), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_results_nearest!(config::OSRMConfig, max_results::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_results_nearest(config.ptr, Cint(max_results), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_default_radius!(config::OSRMConfig, radius::Real)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_default_radius(config.ptr, Cdouble(radius), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_max_alternatives!(config::OSRMConfig, max_alternatives::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_max_alternatives(config.ptr, Cint(max_alternatives), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_use_mmap!(config::OSRMConfig, use_mmap::Bool)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_use_mmap(config.ptr, use_mmap, _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_use_shared_memory!(config::OSRMConfig, use_shm::Bool)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_use_shared_memory(config.ptr, use_shm, _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_dataset_name!(config::OSRMConfig, dataset_name::Union{AbstractString,Nothing})
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_dataset_name(config.ptr, _cstring_or_null(dataset_name), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_memory_file!(config::OSRMConfig, memory_file::Union{AbstractString,Nothing})
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_memory_file(config.ptr, _cstring_or_null(memory_file), _error_ptr(error_ptr))
        nothing
    end
    config
end

function set_verbosity!(config::OSRMConfig, verbosity::Union{AbstractString,Nothing})
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_set_verbosity(config.ptr, _cstring_or_null(verbosity), _error_ptr(error_ptr))
        nothing
    end
    config
end

function disable_feature_dataset!(config::OSRMConfig, dataset_name::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_disable_feature_dataset(config.ptr, _cstring(dataset_name), _error_ptr(error_ptr))
        nothing
    end
    config
end

function clear_disabled_feature_datasets!(config::OSRMConfig)
    _call_with_error() do error_ptr
        CWrapper.osrmc_config_clear_disabled_feature_datasets(config.ptr, _error_ptr(error_ptr))
        nothing
    end
    config
end

end
