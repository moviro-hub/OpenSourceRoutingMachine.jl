module Graph

using CEnum
using ..OpenSourceRoutingMachine: OSRM_jll, Verbosity, verbosity_enum_to_string,
    VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG

"""
    Profile

Selects the routing profile for OSRM dataset generation (`PROFILE_CAR`, `PROFILE_BICYCLE`, `PROFILE_FOOT`).
"""
@cenum(
    Profile::Int32, begin
        PROFILE_CAR = 0
        PROFILE_BICYCLE = 1
        PROFILE_FOOT = 2
    end
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

include("extract.jl")
include("partition.jl")
include("customize.jl")
include("contract.jl")

end # module Graph
