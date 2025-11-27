function extract_cmd(
        osm_path::AbstractString;
        profile::ProfileType = Profile.car,
        extra_args::Vector{String} = String[],
    )
    profile_path = profile_lua_path(profile)
    args = String["-p", profile_path, osm_path]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_extract(), args)
end

"""
    extract(osm_path; profile=Profile.car, extra_args=String[])

Runs the bundled `osrm-extract` with the correct Lua profile, ensuring graph
builds behave the same on every machine.

OSRM 6.0 automatically creates output files based on the input file name in the
same directory as the input file.
"""
function extract(
        osm_path::AbstractString;
        profile::ProfileType = Profile.car,
        extra_args::Vector{String} = String[],
    )
    cmd = extract_cmd(osm_path; profile = profile, extra_args = extra_args)
    run_or_throw(cmd)
end
