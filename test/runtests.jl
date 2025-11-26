# Main test runner for OpenSourceRoutingMachine.jl
# Tests are organized to match the source file structure in src/
using Test
using OSRM_jll
using boost_jll
using libosrmc_jll
using OpenSourceRoutingMachine

@info "=" ^ 60
@info "OpenSourceRoutingMachine.jl Test Suite"
@info "=" ^ 60

# Include test modules in order - they define modules
# These need to be included at the top level, not inside a testset
include("test_data.jl")
include("fixtures.jl")

# Run all test suites organized by source module
@testset "OpenSourceRoutingMachine" begin
    # Tests organized to match src/ structure:
    # - graph.jl → graph_tests.jl
    # - route.jl → route_tests.jl
    # - match.jl → match_tests.jl
    # - nearest.jl → nearest_tests.jl
    # - trip.jl → trip_tests.jl
    # - tile.jl → tile_tests.jl
    # - integration_tests.jl (cross-module tests)

    @info "\n" * "=" ^ 60
    @info "Running Graph Tests (src/graph.jl)"
    @info "=" ^ 60
    include("graph_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Route Tests (src/route.jl)"
    @info "=" ^ 60
    include("route_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Match Tests (src/match.jl)"
    @info "=" ^ 60
    include("match_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Nearest Tests (src/nearest.jl)"
    @info "=" ^ 60
    include("nearest_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Trip Tests (src/trip.jl)"
    @info "=" ^ 60
    include("trip_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Tile Tests (src/tile.jl)"
    @info "=" ^ 60
    include("tile_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Integration Tests (cross-module)"
    @info "=" ^ 60
    if isfile(joinpath(@__DIR__, "integration_tests.jl"))
        include("integration_tests.jl")
    end
end

@info "\n" * "=" ^ 60
@info "All tests completed!"
@info "=" ^ 60
