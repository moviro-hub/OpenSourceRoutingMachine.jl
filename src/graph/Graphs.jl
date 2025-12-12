module Graphs

using CEnum
using ..OpenSourceRoutingMachine: OSRM_jll

"""
    Profile

Selects the routing profile for OSRM dataset generation (`car`, `bicycle`, `foot`).
"""
@cenum(Profile::Int32, begin
    car = 0
    bicycle = 1
    foot = 2
end)

const ProfileType = Profile

export
    Profile,
    ProfileType,
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
