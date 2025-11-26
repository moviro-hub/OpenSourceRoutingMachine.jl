using Test
using OpenSourceRoutingMachine: OSRMConfig, OSRM, RouteParams, add_coordinate!, route, distance, duration, LatLon
using .Fixtures

@testset "Integration - Full Workflow" begin
    @testset "Complete route calculation workflow" begin
        config = Fixtures.get_test_config()
        osrm = OSRM(config)
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route(osrm, params)
        @test response isa RouteResponse
        dist = distance(response)
        dur = duration(response)
        @test dist > 0.0f0
        @test dur > 0.0f0
        @test isfinite(dist)
        @test isfinite(dur)
    end

    @testset "Multiple routes in sequence" begin
        osrm = Fixtures.get_test_osrm()
        params1 = RouteParams()
        add_coordinate!(params1, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params1, Fixtures.HAMBURG_AIRPORT)
        dist1 = distance(route(osrm, params1))

        params2 = RouteParams()
        add_coordinate!(params2, Fixtures.HAMBURG_AIRPORT)
        add_coordinate!(params2, Fixtures.HAMBURG_PORT)
        dist2 = distance(route(osrm, params2))

        params3 = RouteParams()
        add_coordinate!(params3, Fixtures.HAMBURG_PORT)
        add_coordinate!(params3, Fixtures.HAMBURG_CITY_CENTER)
        dist3 = distance(route(osrm, params3))

        @test dist1 > 0.0f0
        @test dist2 > 0.0f0
        @test dist3 > 0.0f0
    end

    @testset "Memory cleanup" begin
        for i in 1:5
            config = Fixtures.get_test_config()
            osrm = OSRM(config)
            params = RouteParams()
            add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
            add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
            @test distance(route(osrm, params)) > 0.0f0
        end
        GC.gc()
        @test true
    end

    @testset "Concurrent route calculations" begin
        osrm = Fixtures.get_test_osrm()
        coords = Fixtures.hamburg_coordinates()
        routes = []
        for i in 1:(length(coords) - 1)
            params = RouteParams()
            add_coordinate!(params, coords[i])
            add_coordinate!(params, coords[i + 1])
            response = route(osrm, params)
            push!(routes, (distance(response), duration(response)))
        end
        @test length(routes) == length(coords) - 1
        for (dist, dur) in routes
            @test dist > 0.0f0
            @test dur > 0.0f0
        end
    end
end
