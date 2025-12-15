"""
    contract(osrm_base_path; verbosity=VERBOSITY_INFO, threads=nothing, segment_speed_file=String[], turn_penalty_file=String[], edge_weight_updates_over_factor=0.0, parse_conditionals_from_now=0, time_zone_file="")

Wraps `osrm-contract` so CH pipelines can be triggered from Julia without invoking shell scripts manually.

# Arguments
- `osrm_base_path`: Path to input .osrm file (without extension)
- `verbosity`: Log verbosity level (VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG; default: VERBOSITY_INFO)
- `threads`: Number of threads to use (default: `nothing` to use hardware concurrency)
- `segment_speed_file`: Vector of lookup file paths containing nodeA, nodeB, speed data (default: String[])
- `turn_penalty_file`: Vector of lookup file paths containing from_, to_, via_nodes, and turn penalties (default: String[])
- `edge_weight_updates_over_factor`: Factor for logging edge weight updates (default: 0.0)
- `parse_conditionals_from_now`: UTC timestamp for evaluating conditional turn restrictions (default: 0)
- `time_zone_file`: GeoJSON file containing time zone boundaries for conditional parsing (default: "")

# Examples
```julia
contract("path/to/base.osrm")
contract("path/to/base.osrm", threads = 4, verbosity = VERBOSITY_DEBUG)
contract("path/to/base.osrm", segment_speed_file = ["speeds.csv"], time_zone_file = "timezones.geojson")
```
"""
function contract(
        osrm_base_path::AbstractString;
        verbosity::Verbosity = VERBOSITY_INFO,
        threads::Union{Int, Nothing} = nothing,
        segment_speed_file::Vector{String} = String[],
        turn_penalty_file::Vector{String} = String[],
        edge_weight_updates_over_factor::Float64 = 0.0,
        parse_conditionals_from_now::Int64 = 0,
        time_zone_file::String = "",
    )
    args = String[]

    # Verbosity - convert enum to string
    verbosity_str = verbosity_enum_to_string(verbosity)
    if verbosity_str != "INFO"  # Only add if non-default
        push!(args, "--verbosity")
        push!(args, verbosity_str)
    end

    # Threads
    if threads !== nothing
        push!(args, "--threads")
        push!(args, string(threads))
    end

    # Segment speed files (can be multiple)
    for path in segment_speed_file
        push!(args, "--segment-speed-file")
        push!(args, path)
    end

    # Turn penalty files (can be multiple)
    for path in turn_penalty_file
        push!(args, "--turn-penalty-file")
        push!(args, path)
    end

    # Edge weight updates over factor
    if edge_weight_updates_over_factor != 0.0
        push!(args, "--edge-weight-updates-over-factor")
        push!(args, string(edge_weight_updates_over_factor))
    end

    # Parse conditionals from now
    if parse_conditionals_from_now != 0
        push!(args, "--parse-conditionals-from-now")
        push!(args, string(parse_conditionals_from_now))
    end

    # Time zone file
    if !isempty(time_zone_file)
        push!(args, "--time-zone-file")
        push!(args, time_zone_file)
    end

    # Input file (positional, goes last)
    push!(args, osrm_base_path)

    cmd = command_with_args(OSRM_jll.osrm_contract(), args)
    run_or_throw(cmd)
end
