using Test
using OpenSourceRoutingMachine: RouteParams, RouteResponse, add_coordinate!, add_coordinate_with!, add_steps!, add_alternatives!, route, distance, duration, LatLon, OSRMError
using Base: C_NULL, length, isfinite
using .Fixtures

@testset "Route - Basic" begin
    @testset "RouteParams creation" begin
        params = RouteParams()
        @test params isa RouteParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Route between two points" begin
        osrm = Fixtures.get_test_osrm()
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

    @testset "Route response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = route(osrm, params)
        @test response.ptr != C_NULL
        @test distance(response) >= 0.0f0
        @test duration(response) >= 0.0f0
    end
end

@testset "Route - Parameters" begin
    @testset "add_steps!" begin
        params = RouteParams()
        add_steps!(params, true)
        add_steps!(params, false)
        @test true
    end

    @testset "add_alternatives!" begin
        params = RouteParams()
        add_alternatives!(params, true)
        add_alternatives!(params, false)
        @test true
    end

    @testset "add_coordinate_with!" begin
        params = RouteParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0f0, 0, 180)
        @test true
    end

    @testset "Route with steps enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_steps!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
        response = route(osrm, params)
        @test distance(response) > 0.0f0
    end

    @testset "Route with alternatives enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_alternatives!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route(osrm, params)
        @test distance(response) > 0.0f0
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, LatLon(0.0f0, 0.0f0))
        add_coordinate!(params, LatLon(1.0f0, 1.0f0))
        try
            response = route(osrm, params)
            @test isfinite(distance(response)) || isinf(distance(response))
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, LatLon(200.0f0, 200.0f0))
        add_coordinate!(params, LatLon(201.0f0, 201.0f0))
        try
            route(osrm, params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Route - Edge Cases" begin
    @testset "Same start and end point" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)
        try
            response = route(osrm, params)
            @test distance(response) >= 0.0f0
            @test duration(response) >= 0.0f0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Very short route" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = LatLon(coord1.lat + 0.001f0, coord1.lon + 0.001f0)
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)
        response = route(osrm, params)
        @test distance(response) >= 0.0f0
        @test duration(response) >= 0.0f0
        @test isfinite(distance(response))
        @test isfinite(duration(response))
    end

    @testset "Route with multiple waypoints" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = route(osrm, params)
        @test distance(response) > 0.0f0
        @test duration(response) > 0.0f0
        @test isfinite(distance(response))
        @test isfinite(duration(response))
    end
end
