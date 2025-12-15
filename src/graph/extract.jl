"""
    extract(osm_path; profile=PROFILE_CAR, verbosity=VERBOSITY_INFO, data_version="", threads=nothing, small_component_size=1000, with_osm_metadata=false, parse_conditional_restrictions=false, location_dependent_data=String[], disable_location_cache=false, dump_nbg_graph=false)

Runs the `osrm-extract` command with a Lua profile, either a default profile (PROFILE_CAR, PROFILE_BICYCLE, PROFILE_FOOT) or a custom profile path.

# Arguments
- `osm_path`: Path to input OSM file (.osm, .osm.bz2, or .osm.pbf format)
- `profile`: Lua routing profile (PROFILE_CAR, PROFILE_BICYCLE, PROFILE_FOOT, or custom path)
- `verbosity`: Log verbosity level (VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG; default: VERBOSITY_INFO)
- `data_version`: Data version string (default: "")
- `threads`: Number of threads to use (default: `nothing` to use hardware concurrency)
- `small_component_size`: Minimum nodes for strongly-connected component (default: 1000)
- `with_osm_metadata`: Use OSM metadata during parsing (default: false)
- `parse_conditional_restrictions`: Save conditional restrictions for contraction (default: false)
- `location_dependent_data`: Vector of GeoJSON file paths for location-dependent data (default: String[])
- `disable_location_cache`: Disable internal nodes locations cache (default: false)
- `dump_nbg_graph`: Dump raw node-based graph for debugging (default: false)

# Examples
```julia
extract("path/to/osm.pbf")
extract("path/to/osm.pbf", profile = PROFILE_CAR)
extract("path/to/osm.pbf", profile = "path/to/profile.lua")
extract("path/to/osm.pbf", threads = 4, verbosity = VERBOSITY_DEBUG)
extract("path/to/osm.pbf", location_dependent_data = ["data.geojson"], with_osm_metadata = true)
```
"""
function extract(
        osm_path::AbstractString;
        profile::Union{Profile, String} = PROFILE_CAR,
        verbosity::Verbosity = VERBOSITY_INFO,
        data_version::String = "",
        threads::Union{Int, Nothing} = nothing,
        small_component_size::Int = 1000,
        with_osm_metadata::Bool = false,
        parse_conditional_restrictions::Bool = false,
        location_dependent_data::Vector{String} = String[],
        disable_location_cache::Bool = false,
        dump_nbg_graph::Bool = false
    )
    args = String[]

    # Profile (required)
    if isa(profile, Profile)
        profile_path_val = profile_path(profile)
    else
        profile_path_val = profile
    end
    push!(args, "--profile")
    push!(args, profile_path_val)

    # Verbosity - convert enum to string
    verbosity_str = verbosity_enum_to_string(verbosity)
    if verbosity_str != "INFO"  # Only add if non-default
        push!(args, "--verbosity")
        push!(args, verbosity_str)
    end

    # Data version
    if !isempty(data_version)
        push!(args, "--data-version")
        push!(args, data_version)
    end

    # Threads
    if threads !== nothing
        push!(args, "--threads")
        push!(args, string(threads))
    end

    # Small component size
    if small_component_size != 1000  # Only add if non-default
        push!(args, "--small-component-size")
        push!(args, string(small_component_size))
    end

    # Boolean flags (only add if true)
    if with_osm_metadata
        push!(args, "--with-osm-metadata")
    end

    if parse_conditional_restrictions
        push!(args, "--parse-conditional-restrictions")
    end

    if disable_location_cache
        push!(args, "--disable-location-cache")
    end

    if dump_nbg_graph
        push!(args, "--dump-nbg-graph")
    end

    # Location-dependent data (can be multiple)
    for path in location_dependent_data
        push!(args, "--location-dependent-data")
        push!(args, path)
    end

    # Input file (positional, goes last)
    push!(args, osm_path)

    cmd = command_with_args(OSRM_jll.osrm_extract(), args)
    run_or_throw(cmd)
end
