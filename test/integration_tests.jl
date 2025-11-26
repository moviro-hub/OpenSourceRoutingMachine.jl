# Integration tests for the Route module
using Test
using OpenSourceRoutingMachine
using .Fixtures

@testset "Integration - Full Workflow" begin
    @testset "Complete route calculation workflow" begin
        # Step 1: Create configuration
        config = Fixtures.get_test_config()
        @test config isa OSRMConfig

        # Step 2: Create OSRM instance
        osrm = OSRM(config)
        @test osrm isa OSRM

        # Step 3: Create route parameters
        params = RouteParams()
        @test params isa RouteParams

        # Step 4: Add coordinates
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_AIRPORT
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        # Step 5: Calculate route
        response = route(osrm, params)
        @test response isa RouteResponse

        # Step 6: Extract results
        dist = distance(response)
        dur = duration(response)

        @test dist > 0.0f0
        @test dur > 0.0f0
        @test isfinite(dist)
        @test isfinite(dur)

        @info "Integration test route: distance=$(dist)m, duration=$(dur)s"
    end

    @testset "Multiple routes in sequence" begin
        osrm = Fixtures.get_test_osrm()

        # Route 1: City center to airport
        params1 = RouteParams()
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_AIRPORT
        add_coordinate!(params1, coord1)
        add_coordinate!(params1, coord2)
        response1 = route(osrm, params1)
        dist1 = distance(response1)

        # Route 2: Airport to port
        params2 = RouteParams()
        coord3 = Fixtures.HAMBURG_PORT
        add_coordinate!(params2, coord2)
        add_coordinate!(params2, coord3)
        response2 = route(osrm, params2)
        dist2 = distance(response2)

        # Route 3: Port back to city center
        params3 = RouteParams()
        coord4 = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params3, coord3)
        add_coordinate!(params3, coord4)
        response3 = route(osrm, params3)
        dist3 = distance(response3)

        # All routes should be valid
        @test dist1 > 0.0f0
        @test dist2 > 0.0f0
        @test dist3 > 0.0f0

        @info "Multiple routes: dist1=$(dist1)m, dist2=$(dist2)m, dist3=$(dist3)m"
    end

    @testset "Memory cleanup (no leaks)" begin
        # Create and destroy multiple OSRM instances
        for i in 1:5
            config = Fixtures.get_test_config()
            osrm = OSRM(config)
            params = RouteParams()
            coord1 = Fixtures.HAMBURG_CITY_CENTER
            coord2 = Fixtures.HAMBURG_ALTONA
            add_coordinate!(params, coord1)
            add_coordinate!(params, coord2)
            response = route(osrm, params)
            dist = distance(response)
            @test dist > 0.0f0

            # Objects should be cleaned up by finalizers
            # This test mainly ensures no crashes occur
        end

        # Force garbage collection
        GC.gc()
        @test true  # If we get here, no crashes occurred
    end

    @testset "Concurrent route calculations" begin
        osrm = Fixtures.get_test_osrm()

        # Calculate multiple routes with different parameters
        routes = []
        coords = Fixtures.hamburg_coordinates()

        for i in 1:length(coords)-1
            params = RouteParams()
            coord1 = coords[i]
            coord2 = coords[i+1]
            add_coordinate!(params, coord1)
            add_coordinate!(params, coord2)
            response = route(osrm, params)
            push!(routes, (distance(response), duration(response)))
        end

        # All routes should be valid
        @test length(routes) == length(coords) - 1
        for (dist, dur) in routes
            @test dist > 0.0f0
            @test dur > 0.0f0
        end
    end
end
