module Graphs

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

export
    # enums
    Profile, PROFILE_CAR, PROFILE_BICYCLE, PROFILE_FOOT,
    # Types
    OSRMCommandError,
    # functions
    profile_path,
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
