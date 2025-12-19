"""
    partition(osrm_base_path; verbosity=VERBOSITY_INFO, threads=nothing, balance=1.2, boundary=0.25, optimizing_cuts=10, small_component_size=1000, max_cell_sizes=[128, 4096, 65536, 2097152])

Executes `osrm-partition` on an existing `.osrm` file so MLD preparations stay in Julia scripts rather than shell pipelines.

# Arguments
- `osrm_base_path`: Path to input .osrm file (without extension)
- `verbosity`: Log verbosity level (VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG; default: VERBOSITY_INFO)
- `threads`: Number of threads to use (default: `nothing` to use hardware concurrency)
- `balance`: Balance for left and right side in single bisection (default: 1.2)
- `boundary`: Percentage of embedded nodes to contract as sources and sinks (default: 0.25)
- `optimizing_cuts`: Number of cuts to use for optimizing a single bisection (default: 10)
- `small_component_size`: Size threshold for small components (default: 1000)
- `max_cell_sizes`: Maximum cell sizes starting from level 1, comma-separated (default: [128, 4096, 65536, 2097152])

# Examples
```julia
partition("path/to/base.osrm")
partition("path/to/base.osrm", threads = 4, verbosity = VERBOSITY_DEBUG)
partition("path/to/base.osrm", balance = 1.5, boundary = 0.3)
partition("path/to/base.osrm", max_cell_sizes = [256, 8192, 131072])
```
"""
function partition(
        osrm_base_path::AbstractString;
        verbosity::Verbosity = VERBOSITY_INFO,
        threads::Union{Int, Nothing} = nothing,
        balance::Float64 = 1.2,
        boundary::Float64 = 0.25,
        optimizing_cuts::Int = 10,
        small_component_size::Int = 1000,
        max_cell_sizes::Vector{Int} = [128, 4096, 65536, 2097152],
    )
    cmd = `$(OSRM_jll.osrm_partition())`

    # Verbosity - convert enum to string
    verbosity_str = verbosity_enum_to_string(verbosity)
    if verbosity_str != "INFO"  # Only add if non-default
        cmd = `$cmd --verbosity $verbosity_str`
    end

    # Threads
    if threads !== nothing
        cmd = `$cmd --threads $(string(threads))`
    end

    # Balance
    if balance != 1.2  # Only add if non-default
        cmd = `$cmd --balance $(string(balance))`
    end

    # Boundary
    if boundary != 0.25  # Only add if non-default
        cmd = `$cmd --boundary $(string(boundary))`
    end

    # Optimizing cuts
    if optimizing_cuts != 10  # Only add if non-default
        cmd = `$cmd --optimizing-cuts $(string(optimizing_cuts))`
    end

    # Small component size
    if small_component_size != 1000  # Only add if non-default
        cmd = `$cmd --small-component-size $(string(small_component_size))`
    end

    # Max cell sizes - convert vector to comma-separated string
    default_max_cell_sizes = [128, 4096, 65536, 2097152]
    if max_cell_sizes != default_max_cell_sizes
        max_cell_sizes_str = join(string.(max_cell_sizes), ",")
        cmd = `$cmd --max-cell-sizes $max_cell_sizes_str`
    end

    # Input file (positional, goes last)
    cmd = `$cmd $osrm_base_path`

    return run(cmd)
end
