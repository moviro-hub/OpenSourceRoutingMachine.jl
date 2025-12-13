module Graphs

using CEnum
using ..OpenSourceRoutingMachine: OSRM_jll

"""
    Profile

Selects the routing profile for OSRM dataset generation (`profile_car`, `profile_bicycle`, `profile_foot`).
"""
@cenum(
    Profile::Int32, begin
        profile_car = 0
        profile_bicycle = 1
        profile_foot = 2
    end
)

const ProfileType = Profile

export
    Profile,
    ProfileType,
    profile_car,
    profile_bicycle,
    profile_foot,
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
