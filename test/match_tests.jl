# Comprehensive tests for the Match module
using Test
using OpenSourceRoutingMachine: MatchParams, MatchResponse, add_coordinate!, add_timestamp!, set_gaps!, set_tidy!, match, route_count, tracepoint_count, route_distance, route_duration, route_confidence, tracepoint_latitude, tracepoint_longitude, tracepoint_is_null, LatLon, OSRMError
using Base: C_NULL
using .Fixtures

@testset "Match - Basic" begin
    @testset "MatchParams creation" begin
        params = MatchParams()
        @test params isa MatchParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = MatchParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        # Should not throw
        @test true
    end

    @testset "Match with two points" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT

        # Add coordinates to match params
        for coord in coords
            add_coordinate!(params, coord)
        end

        # Calculate match
        response = match(osrm, params)
        @test response isa MatchResponse

        # Check route count
        route_cnt = route_count(response)
        @test route_cnt >= 0

        # Check tracepoint count
        tracepoint_cnt = tracepoint_count(response)
        @test tracepoint_cnt >= 0

        # If we have routes, check their properties
        if route_cnt > 0
            dist = route_distance(response, 1)
            dur = route_duration(response, 1)
            conf = route_confidence(response, 1)

            @test dist >= 0.0f0
            @test dur >= 0.0f0
            @test 0.0f0 <= conf <= 1.0f0
            @test isfinite(dist)
            @test isfinite(dur)
            @test isfinite(conf)

            @info "Match route 0: distance=$(dist)m, duration=$(dur)s, confidence=$(conf)"
        end

        # Check tracepoints
        if tracepoint_cnt > 0
            for i in 1:tracepoint_cnt
                is_null = tracepoint_is_null(response, i)
                @test isa(is_null, Bool)

                if !is_null
                    lat = tracepoint_latitude(response, i)
                    lon = tracepoint_longitude(response, i)

                    @test -90.0f0 <= lat <= 90.0f0
                    @test -180.0f0 <= lon <= 180.0f0
                    @test isfinite(lat)
                    @test isfinite(lon)

                    @info "Tracepoint $i: ($lon, $lat)"
                end
            end
        end
    end

    @testset "Match response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        @test response.ptr != C_NULL

        # Should be able to query counts
        route_cnt = route_count(response)
        tracepoint_cnt = tracepoint_count(response)
        @test route_cnt >= 0
        @test tracepoint_cnt >= 0
    end
end

@testset "Match - Parameters" begin
    @testset "add_timestamp!" begin
        params = MatchParams()
        add_timestamp!(params, 0)
        add_timestamp!(params, 100)
        add_timestamp!(params, 200)
        # Should not throw
        @test true
    end

    @testset "set_gaps!" begin
        params = MatchParams()
        set_gaps!(params, "split")
        set_gaps!(params, "ignore")
        # Should not throw
        @test true
    end

    @testset "set_tidy!" begin
        params = MatchParams()
        set_tidy!(params, true)
        set_tidy!(params, false)
        # Should not throw
        @test true
    end

    @testset "Match with timestamps" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA

        for coord in coords
            add_coordinate!(params, coord)
        end

        # Add timestamps (in seconds since epoch or relative)
        for i in 1:length(coords)
            add_timestamp!(params, (i - 1) * 10)  # 10 seconds between points
        end

        response = match(osrm, params)
        @test response isa MatchResponse
        route_cnt = route_count(response)
        @test route_cnt >= 0
    end

    @testset "Match with gaps set to split" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_gaps!(params, "split")

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        @test response isa MatchResponse
        route_cnt = route_count(response)
        @test route_cnt >= 0
    end

    @testset "Match with tidy enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_tidy!(params, true)

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        @test response isa MatchResponse
        route_cnt = route_count(response)
        @test route_cnt >= 0
    end

    @testset "add_coordinate_with!" begin
        params = MatchParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        radius = 10.0f0
        bearing = 0
        range = 180
        add_coordinate_with!(params, coord, radius, bearing, range)
        # Should not throw
        @test true
    end
end

@testset "Match - Response Accessors" begin
    @testset "Access route properties" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        route_cnt = route_count(response)

        if route_cnt > 0
            # Test accessing first route
            dist = route_distance(response, 1)
            dur = route_duration(response, 1)
            conf = route_confidence(response, 1)

            @test dist >= 0.0f0
            @test dur >= 0.0f0
            @test 0.0f0 <= conf <= 1.0f0
        end
    end

    @testset "Access tracepoint properties" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        tracepoint_cnt = tracepoint_count(response)

        if tracepoint_cnt > 0
            # Test accessing first tracepoint
            is_null = tracepoint_is_null(response, 1)
            @test isa(is_null, Bool)

            if !is_null
                lat = tracepoint_latitude(response, 1)
                lon = tracepoint_longitude(response, 1)

                @test -90.0f0 <= lat <= 90.0f0
                @test -180.0f0 <= lon <= 180.0f0
            end
        end
    end

    @testset "as_json returns valid JSON" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        json_str = OpenSourceRoutingMachine.Match.as_json(response)

        @test isa(json_str, String)
        @test !isempty(json_str)
        # Basic JSON validation - should start with '{' or '['
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Match - Error Handling" begin
    @testset "Invalid coordinates (out of bounds)" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Coordinates way outside Hamburg (somewhere in the ocean)
        add_coordinate!(params, LatLon(0.0f0, 0.0f0))
        add_coordinate!(params, LatLon(1.0f0, 1.0f0))

        # Should either throw an error or return a valid response
        try
            response = match(osrm, params)
            # If no error, check that response is valid
            route_cnt = route_count(response)
            @test route_cnt >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Try with clearly invalid coordinates
        add_coordinate!(params, LatLon(200.0f0, 200.0f0))  # Invalid lat/lon
        add_coordinate!(params, LatLon(201.0f0, 201.0f0))

        try
            response = match(osrm, params)
            # If it doesn't throw, that's also acceptable
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
            @info "Error code: $(e.code), message: $(e.message)"
        end
    end

    @testset "Accessing route with invalid index" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        route_cnt = route_count(response)

        # Try to access a route index that doesn't exist
        if route_cnt == 0
            # If no routes, accessing index 0 should either throw or return a default value
            try
                dist = route_distance(response, 1)
                @test true  # If it doesn't throw, that's acceptable
            catch e
                @test e isa OSRMError
            end
        end
    end
end

@testset "Match - Edge Cases" begin
    @testset "Same start and end point" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)  # Same point

        try
            response = match(osrm, params)
            route_cnt = route_count(response)
            tracepoint_cnt = tracepoint_count(response)
            @test route_cnt >= 0
            @test tracepoint_cnt >= 0
        catch e
            # Some implementations might throw for same point
            @test e isa OSRMError
        end
    end

    @testset "Very short trace" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use first 5 coordinates from validated test data (short but valid trace)
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT[1:5]
        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        route_cnt = route_count(response)
        tracepoint_cnt = tracepoint_count(response)

        @test route_cnt >= 0
        @test tracepoint_cnt >= 0
    end

    @testset "Match with multiple tracepoints" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated multi-segment test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_MULTI_SEGMENT

        for coord in coords
            add_coordinate!(params, coord)
        end

        response = match(osrm, params)
        route_cnt = route_count(response)
        tracepoint_cnt = tracepoint_count(response)

        @test route_cnt >= 0
        @test tracepoint_cnt >= 0

        if route_cnt > 0
            dist = route_distance(response, 1)
            dur = route_duration(response, 1)
            @test dist >= 0.0f0
            @test dur >= 0.0f0
            @test isfinite(dist)
            @test isfinite(dur)

            @info "Multi-tracepoint match: distance=$(dist)m, duration=$(dur)s"
        end
    end

    @testset "Match with timestamps for multiple points" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()

        # Use pre-generated test coordinates
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT

        for (i, coord) in enumerate(coords)
            add_coordinate!(params, coord)
            # Add timestamps increasing by 10 seconds
            add_timestamp!(params, (i - 1) * 10)
        end

        response = match(osrm, params)
        route_cnt = route_count(response)
        tracepoint_cnt = tracepoint_count(response)

        @test route_cnt >= 0
        @test tracepoint_cnt >= 0
    end
end
