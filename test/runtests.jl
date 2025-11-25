# Main test runner for OpenSourceRoutingMachine.jl
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

# Run all test suites
@testset "OpenSourceRoutingMachine" begin
    @info "\n" * "=" ^ 60
    @info "Running Route Tests"
    @info "=" ^ 60

    # Include route tests - they will run their own testsets
    include("route_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Match Tests"
    @info "=" ^ 60

    # Include match tests - they will run their own testsets
    include("match_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Nearest Tests"
    @info "=" ^ 60

    # Include nearest tests - they will run their own testsets
    include("nearest_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Trip Tests"
    @info "=" ^ 60

    include("trip_tests.jl")

    @info "\n" * "=" ^ 60
    @info "Running Integration Tests"
    @info "=" ^ 60

    # Include integration tests - they will run their own testsets
    if isfile(joinpath(@__DIR__, "integration_tests.jl"))
        include("integration_tests.jl")
    end
end

@info "\n" * "=" ^ 60
@info "All tests completed!"
@info "=" ^ 60
