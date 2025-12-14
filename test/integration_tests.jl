using Test
using OpenSourceRoutingMachine: OSRMConfig, OSRM, Position
using OpenSourceRoutingMachine.Routes: RouteParams, RouteResponse, add_coordinate!, route, route_response
using .Fixtures

@testset "Integration - Full Workflow" begin
    @testset "Complete route calculation workflow" begin
        config = Fixtures.get_test_config()
        osrm = OSRM(config)
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route_response(osrm, params)
        @test response isa RouteResponse
    end

    @testset "Multiple routes in sequence" begin
        osrm = Fixtures.get_test_osrm()
        params1 = RouteParams()
        add_coordinate!(params1, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params1, Fixtures.HAMBURG_AIRPORT)
        response1 = route_response(osrm, params1)
        @test response1 isa RouteResponse

        params2 = RouteParams()
        add_coordinate!(params2, Fixtures.HAMBURG_AIRPORT)
        add_coordinate!(params2, Fixtures.HAMBURG_PORT)
        response2 = route_response(osrm, params2)
        @test response2 isa RouteResponse

        params3 = RouteParams()
        add_coordinate!(params3, Fixtures.HAMBURG_PORT)
        add_coordinate!(params3, Fixtures.HAMBURG_CITY_CENTER)
        response3 = route_response(osrm, params3)
        @test response3 isa RouteResponse
    end

    @testset "Memory cleanup" begin
        for i in 1:5
            config = Fixtures.get_test_config()
            osrm = OSRM(config)
            params = RouteParams()
            add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
            add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
            response = route_response(osrm, params)
            @test response isa RouteResponse
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
            response = route_response(osrm, params)
            @test response isa RouteResponse
            push!(routes, response)
        end
        @test length(routes) == length(coords) - 1
        for response in routes
            @test response isa RouteResponse
        end
    end
end
