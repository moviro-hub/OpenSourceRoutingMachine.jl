"""
    extract(osm_path; profile=PROFILE_CAR, extra_args=String[])

Runs the `osrm-extract` command with a Lua profile, either a default profile (PROFILE_CAR, PROFILE_BICYCLE, PROFILE_FOOT) or a custom profile path.
extra_args can be used to pass additional arguments to the `osrm-extract` command.

# Examples
```julia
extract("path/to/osm.pbf")
extract("path/to/osm.pbf", profile = PROFILE_CAR)
extract("path/to/osm.pbf", profile = "path/to/profile.lua")
```
"""
function extract(
        osm_path::AbstractString;
        profile::Union{ProfileType, String} = PROFILE_CAR,
        extra_args::Vector{String} = String[],
    )
    cmd = extract_cmd(osm_path, profile; extra_args = extra_args)
    run_or_throw(cmd)
end

#  Use with default profiles
function extract_cmd(
        osm_path::AbstractString,
        profile::ProfileType;
        extra_args::Vector{String} = String[],
    )
    profile_path = profile_lua_path(profile)
    args = String["-p", profile_path, osm_path]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_extract(), args)
end

#  Use with custom profile path
function extract_cmd(
        osm_path::AbstractString,
        profile_path::String;
        extra_args::Vector{String} = String[],
    )
    args = String["-p", profile_path, osm_path]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_extract(), args)
end
