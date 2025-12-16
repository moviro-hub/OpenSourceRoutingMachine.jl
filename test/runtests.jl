using Test
using OpenSourceRoutingMachine

include("TestUtils.jl")

TURN_ON_GRAPH_TESTS = true

@testset "OpenSourceRoutingMachine" begin
    if TURN_ON_GRAPH_TESTS
        include("graph_tests.jl")
    end
    include("instance_tests.jl")
    include("nearest_tests.jl")
    include("route_tests.jl")
    include("table_tests.jl")
    include("match_tests.jl")
    include("trip_tests.jl")
    include("tile_tests.jl")
end
