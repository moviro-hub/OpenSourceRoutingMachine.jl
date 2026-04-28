module Graph

using EnumX
using ..OpenSourceRoutingMachine: OSRM_jll, Verbosity, verbosity_enum_to_string,
    VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG

"""
    Profile

Selects the routing profile for OSRM dataset generation (`PROFILE_CAR`, `PROFILE_BICYCLE`, `PROFILE_FOOT`).
"""
EnumX.@enum(
    Profile::Int32,
    PROFILE_CAR = 0,
    PROFILE_BICYCLE = 1,
    PROFILE_FOOT = 2
)

"""
    profile_path(profile::Profile) -> String

Return the absolute path to the Lua profile corresponding to the provided
`Profile` value, using OSRM's standard profile location.
"""
function profile_path(profile::Profile)::String
    # Convert PROFILE_CAR -> car, PROFILE_BICYCLE -> bicycle, PROFILE_FOOT -> foot
    profile_name = lowercase(replace(string(profile), "PROFILE_" => ""))
    # OSRM stores profiles in the artifact's profiles directory
    artifact_dir = dirname(dirname(OSRM_jll.osrm_extract_path))
    profile_path = joinpath(artifact_dir, "profiles", profile_name * ".lua")
    isfile(profile_path) || error("Could not find Lua profile for $(string(profile)): looked in artifact at $profile_path")
    return profile_path
end

export
    # enums
    Profile, PROFILE_CAR, PROFILE_BICYCLE, PROFILE_FOOT,
    # functions
    profile_path,
    extract,
    partition,
    customize,
    contract

"""
    _run_osrm_cmd(exe, args, positional_path)

Run an OSRM CLI command.  Works around an OSRM/Boost.ProgramOptions bug
where any path argument containing spaces is rejected.

When the path contains a space, all files sharing the same base name are
symlinked into a temporary directory so that OSRM never sees a space.
After the command finishes, any newly created files are moved back to
the original directory.
"""
function _run_osrm_cmd(exe::Cmd, args::Vector{String}, positional_path::String)
    if !contains(positional_path, ' ')
        return run(`$exe $args $positional_path`)
    end

    abs_path = abspath(positional_path)
    dir = dirname(abs_path)
    base = basename(abs_path)

    mktempdir() do tmp_dir
        # Symlink the input file and all sibling files that share
        # the base name (e.g. *.osrm.* graph files).
        for f in readdir(dir)
            if f == base || startswith(f, base * ".")
                symlink(joinpath(dir, f), joinpath(tmp_dir, f))
            end
        end
        tmp_positional = joinpath(tmp_dir, base)

        # Replace any args that reference the original directory
        patched_args = [contains(a, dir) ? replace(a, dir => tmp_dir) : a for a in args]

        result = run(`$exe $patched_args $tmp_positional`)

        # Move any new (non-symlink) files back to the original directory
        for f in readdir(tmp_dir)
            fpath = joinpath(tmp_dir, f)
            if !islink(fpath)
                mv(fpath, joinpath(dir, f); force = true)
            end
        end

        return result
    end
end

include("extract.jl")
include("partition.jl")
include("customize.jl")
include("contract.jl")

end # module Graph
