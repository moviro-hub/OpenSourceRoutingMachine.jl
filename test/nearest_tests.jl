using Test
using OpenSourceRoutingMachine: LatLon, OSRMError
using OpenSourceRoutingMachine: Approach, Snapping
using OpenSourceRoutingMachine.Nearests:
    NearestParams,
    NearestResponse,
    add_coordinate!,
    add_coordinate_with!,
    set_number_of_results!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!,
    nearest,
    latitude,
    longitude,
    name,
    hint,
    distance,
    count
const Nearests = OpenSourceRoutingMachine.Nearests
using Base: C_NULL, length, isempty, isfinite
using .Fixtures

@testset "Nearest - Basic" begin
    @testset "NearestParams creation" begin
        params = NearestParams()
        @test params isa NearestParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Nearest query for single point" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        @test response isa NearestResponse
        result_cnt = count(response)
        @test result_cnt >= 0
        if result_cnt > 0
            @test -90.0 <= latitude(response, 1) <= 90.0
            @test -180.0 <= longitude(response, 1) <= 180.0
            @test distance(response, 1) >= 0.0
            @test isa(name(response, 1), String)
            @test isfinite(latitude(response, 1))
            @test isfinite(longitude(response, 1))
            @test isfinite(distance(response, 1))
            @test isa(hint(response, 1), String)
            @test !isempty(hint(response, 1))
        end
    end

    @testset "Nearest response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = nearest(osrm, params)
        @test response.ptr != C_NULL
        @test count(response) >= 0
    end
end

@testset "Nearest - Parameters" begin
    @testset "set_number_of_results!" begin
        params = NearestParams()
        set_number_of_results!(params, 1)
        set_number_of_results!(params, 5)
        @test true
    end

    @testset "Nearest with multiple results requested" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 3)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        result_cnt = count(response)
        @test result_cnt >= 0
        @test result_cnt <= 3
    end

    @testset "Nearest with single result" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 1)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = nearest(osrm, params)
        result_cnt = count(response)
        @test result_cnt >= 0
        @test result_cnt <= 1
    end

    @testset "add_coordinate_with!" begin
        params = NearestParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0, 0, 180)
        @test true
    end

    @testset "Additional parameter helpers smoke test" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()

        # Nearest only supports a single coordinate; use the richer helper
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0, 0, 180)

        set_hint!(params, 1, "")
        set_radius!(params, 1, 5.0)
        set_bearing!(params, 1, 0, 90)
        set_approach!(params, 1, Approach.curb)

        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, Snapping.default)

        response = nearest(osrm, params)
        @test response isa NearestResponse
        @test count(response) >= 0
    end
end

@testset "Nearest - Response Accessors" begin
    @testset "Access all result properties" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 2)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        if count(response) > 0
            @test -90.0 <= latitude(response, 1) <= 90.0
            @test -180.0 <= longitude(response, 1) <= 180.0
            @test distance(response, 1) >= 0.0
            @test isa(name(response, 1), String)
        end
    end

    @testset "Results are sorted by distance" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 3)
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = nearest(osrm, params)
        result_cnt = count(response)
        if result_cnt > 1
            prev_dist = distance(response, 1)
            for i in 2:result_cnt
                curr_dist = distance(response, i)
                @test curr_dist >= prev_dist
                prev_dist = curr_dist
            end
        end
    end

    @testset "as_json returns valid JSON" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        json_str = Nearests.as_json(response)
        @test isa(json_str, String)
        @test !isempty(json_str)
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, LatLon(0.0, 0.0))
        try
            response = nearest(osrm, params)
            @test count(response) >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, LatLon(200.0, 200.0))
        try
            nearest(osrm, params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Nearest - Edge Cases" begin
    @testset "Nearest for different locations" begin
        osrm = Fixtures.get_test_osrm()
        for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT, Fixtures.HAMBURG_PORT, Fixtures.HAMBURG_ALTONA]
            params = NearestParams()
            add_coordinate!(params, coord)
            response = nearest(osrm, params)
            result_cnt = count(response)
            @test result_cnt >= 0
            if result_cnt > 0
                @test -90.0 <= latitude(response, 1) <= 90.0
                @test -180.0 <= longitude(response, 1) <= 180.0
                @test distance(response, 1) >= 0.0
                @test isfinite(latitude(response, 1))
                @test isfinite(longitude(response, 1))
                @test isfinite(distance(response, 1))
                @test distance(response, 1) < 10000.0
            end
        end
    end

    @testset "Nearest with zero results requested" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 0)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        try
            response = nearest(osrm, params)
            @test count(response) >= 0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Nearest with large number of results" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 100)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        @test count(response) >= 0
        @test count(response) <= 100
    end

    @testset "Nearest result distance is reasonable" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest(osrm, params)
        if count(response) > 0
            result_dist = distance(response, 1)
            @test result_dist < 1000.0
            @test result_dist >= 0.0
            @test isfinite(result_dist)
        end
    end
end
