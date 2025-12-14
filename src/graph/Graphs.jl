module Graphs

using CEnum
using ..OpenSourceRoutingMachine: OSRM_jll

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

const ProfileType = Profile

export
    Profile,
    ProfileType,
    PROFILE_CAR,
    PROFILE_BICYCLE,
    PROFILE_FOOT,
    OSRMCommandError,
    profile_lua_path,
    extract,
    partition,
    customize,
    contract

include("utils.jl")
include("extract.jl")
include("partition.jl")
include("customize.jl")
include("contract.jl")

end # module Graphs
