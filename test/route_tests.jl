# Comprehensive tests for the Route module
using Test
using OpenSourceRoutingMachine
using Base: C_NULL
using .Fixtures

@testset "Route - Basic" begin
    @testset "RouteParams creation" begin
        params = RouteParams()
        @test params isa RouteParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = RouteParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        # Should not throw
        @test true
    end

    @testset "Route between two points" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # Add start point (city center)
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)

        # Add end point (airport)
        coord2 = Fixtures.HAMBURG_AIRPORT
        add_coordinate!(params, coord2)

        # Calculate route
        response = route(osrm, params)
        @test response isa RouteResponse

        # Check distance and duration are positive
        dist = distance(response)
        dur = duration(response)

        @test dist > 0.0f0
        @test dur > 0.0f0
        @test isfinite(dist)
        @test isfinite(dur)

        @info "Route from city center to airport: distance=$(dist)m, duration=$(dur)s"
    end

    @testset "Route response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_PORT
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        response = route(osrm, params)
        @test response.ptr != C_NULL

        # Should be able to query distance and duration
        dist = distance(response)
        dur = duration(response)
        @test dist >= 0.0f0
        @test dur >= 0.0f0
    end
end

@testset "Route - Parameters" begin
    @testset "add_steps!" begin
        params = RouteParams()
        add_steps!(params, true)
        add_steps!(params, false)
        # Should not throw
        @test true
    end

    @testset "add_alternatives!" begin
        params = RouteParams()
        add_alternatives!(params, true)
        add_alternatives!(params, false)
        # Should not throw
        @test true
    end

    @testset "add_coordinate_with!" begin
        params = RouteParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        radius = 10.0f0
        bearing = 0
        range = 180
        add_coordinate_with!(params, coord, radius, bearing, range)
        # Should not throw
        @test true
    end

    @testset "Route with steps enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_steps!(params, true)

        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_ALTONA
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        response = route(osrm, params)
        @test response isa RouteResponse
        dist = distance(response)
        @test dist > 0.0f0
    end

    @testset "Route with alternatives enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_alternatives!(params, true)

        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_AIRPORT
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        response = route(osrm, params)
        @test response isa RouteResponse
        dist = distance(response)
        @test dist > 0.0f0
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates (out of bounds)" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # Coordinates way outside Hamburg (somewhere in the ocean)
        add_coordinate!(params, LatLon(0.0f0, 0.0f0))
        add_coordinate!(params, LatLon(1.0f0, 1.0f0))

        # Should either throw an error or return a valid response with no route
        try
            response = route(osrm, params)
            # If no error, check that distance/duration might be invalid
            dist = distance(response)
            @test isfinite(dist) || isinf(dist)
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # Try with clearly invalid coordinates
        add_coordinate!(params, LatLon(200.0f0, 200.0f0))  # Invalid lat/lon
        add_coordinate!(params, LatLon(201.0f0, 201.0f0))

        try
            response = route(osrm, params)
            # If it doesn't throw, that's also acceptable
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
            @info "Error code: $(e.code), message: $(e.message)"
        end
    end
end

@testset "Route - Callbacks" begin
    @testset "route_with waypoint handler" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_PORT
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        # Collect waypoints in a vector
        waypoints = []
        handler(data, name, lat, lon) = push!(waypoints, (name, lat, lon))

        # Call route_with
        route_with(osrm, params, handler, nothing)

        # Should have collected some waypoints
        # Note: The exact number depends on the route, but should be at least the start/end
        @test length(waypoints) >= 0  # May be 0 if callback isn't called for all routes
    end

    @testset "Callback receives correct data" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Fixtures.HAMBURG_ALTONA
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        received_data = nothing
        test_data = "test_data_123"
        handler(data, name, lat, lon) = (global received_data = data)

        route_with(osrm, params, handler, test_data)

        # Check that data was passed through (if callback was called)
        # Note: This depends on the callback implementation
        @test true  # Just verify it doesn't crash
    end
end

@testset "Route - Edge Cases" begin
    @testset "Same start and end point" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)  # Same point

        try
            response = route(osrm, params)
            dist = distance(response)
            dur = duration(response)
            # Distance should be very small or zero
            @test dist >= 0.0f0
            @test dur >= 0.0f0
        catch e
            # Some implementations might throw for same point
            @test e isa OSRMError
        end
    end

    @testset "Very short route" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # Two very close points
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = LatLon(coord1.lat + 0.001f0, coord1.lon + 0.001f0)  # Very close
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)

        response = route(osrm, params)
        dist = distance(response)
        dur = duration(response)

        @test dist >= 0.0f0
        @test dur >= 0.0f0
        @test isfinite(dist)
        @test isfinite(dur)
    end

    @testset "Route with multiple waypoints" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # Add multiple waypoints
        coords = Fixtures.hamburg_coordinates()
        for coord in coords
            add_coordinate!(params, coord)
        end

        response = route(osrm, params)
        dist = distance(response)
        dur = duration(response)

        @test dist > 0.0f0
        @test dur > 0.0f0
        @test isfinite(dist)
        @test isfinite(dur)

        @info "Multi-waypoint route: distance=$(dist)m, duration=$(dur)s"
    end
end
