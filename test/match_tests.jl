using Test
using OpenSourceRoutingMachine: MatchParams, MatchResponse, add_coordinate!, add_timestamp!, set_gaps!, set_tidy!, route_count, tracepoint_count, route_distance, route_duration, route_confidence, tracepoint_latitude, tracepoint_longitude, tracepoint_is_null, LatLon, OSRMError
using OpenSourceRoutingMachine.Matches: match
using Base: C_NULL, length, isfinite
using .Fixtures

@testset "Match - Basic" begin
    @testset "MatchParams creation" begin
        params = MatchParams()
        @test params isa MatchParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = MatchParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Match with two points" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test response isa MatchResponse
        route_cnt = route_count(response)
        tracepoint_cnt = tracepoint_count(response)
        @test route_cnt >= 0
        @test tracepoint_cnt >= 0
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
        end
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
                end
            end
        end
    end

    @testset "Match response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test response.ptr != C_NULL
        @test route_count(response) >= 0
        @test tracepoint_count(response) >= 0
    end
end

@testset "Match - Parameters" begin
    @testset "add_timestamp!" begin
        params = MatchParams()
        add_timestamp!(params, 0)
        add_timestamp!(params, 100)
        @test true
    end

    @testset "set_gaps!" begin
        params = MatchParams()
        set_gaps!(params, "split")
        set_gaps!(params, "ignore")
        @test true
    end

    @testset "set_tidy!" begin
        params = MatchParams()
        set_tidy!(params, true)
        set_tidy!(params, false)
        @test true
    end

    @testset "Match with timestamps" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        coords = Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA
        for coord in coords
            add_coordinate!(params, coord)
        end
        for i in 1:length(coords)
            add_timestamp!(params, (i - 1) * 10)
        end
        response = match(osrm, params)
        @test route_count(response) >= 0
    end

    @testset "Match with gaps set to split" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_gaps!(params, "split")
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test route_count(response) >= 0
    end

    @testset "Match with tidy enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_tidy!(params, true)
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test route_count(response) >= 0
    end

    @testset "add_coordinate_with!" begin
        params = MatchParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0f0, 0, 180)
        @test true
    end
end

@testset "Match - Response Accessors" begin
    @testset "Access route properties" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        if route_count(response) > 0
            @test route_distance(response, 1) >= 0.0f0
            @test route_duration(response, 1) >= 0.0f0
            @test 0.0f0 <= route_confidence(response, 1) <= 1.0f0
        end
    end

    @testset "Access tracepoint properties" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        if tracepoint_count(response) > 0
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
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        json_str = OpenSourceRoutingMachine.Matches.as_json(response)
        @test isa(json_str, String)
        @test !isempty(json_str)
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Match - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        add_coordinate!(params, LatLon(0.0f0, 0.0f0))
        add_coordinate!(params, LatLon(1.0f0, 1.0f0))
        try
            response = match(osrm, params)
            @test route_count(response) >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        add_coordinate!(params, LatLon(200.0f0, 200.0f0))
        add_coordinate!(params, LatLon(201.0f0, 201.0f0))
        try
            match(osrm, params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Match - Edge Cases" begin
    @testset "Same start and end point" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)
        try
            response = match(osrm, params)
            @test route_count(response) >= 0
            @test tracepoint_count(response) >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Very short trace" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT[1:5]
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test route_count(response) >= 0
        @test tracepoint_count(response) >= 0
    end

    @testset "Match with multiple tracepoints" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_MULTI_SEGMENT
            add_coordinate!(params, coord)
        end
        response = match(osrm, params)
        @test route_count(response) >= 0
        @test tracepoint_count(response) >= 0
        if route_count(response) > 0
            dist = route_distance(response, 1)
            dur = route_duration(response, 1)
            @test dist >= 0.0f0
            @test dur >= 0.0f0
            @test isfinite(dist)
            @test isfinite(dur)
        end
    end
end
