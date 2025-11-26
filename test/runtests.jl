using Test
using OSRM_jll
using boost_jll
using libosrmc_jll
using OpenSourceRoutingMachine

include("test_data.jl")
include("fixtures.jl")

@testset "OpenSourceRoutingMachine" begin
    include("graph_tests.jl")
    include("route_tests.jl")
    include("table_tests.jl")
    include("match_tests.jl")
    include("nearest_tests.jl")
    include("trip_tests.jl")
    include("tile_tests.jl")
    if isfile(joinpath(@__DIR__, "integration_tests.jl"))
        include("integration_tests.jl")
    end
end
