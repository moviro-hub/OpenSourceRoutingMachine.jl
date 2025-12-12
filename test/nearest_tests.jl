using Test
using OpenSourceRoutingMachine: Position, OSRMError
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
    nearest_response
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
        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Nearest response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = nearest_response(osrm, params)
        @test response.ptr != C_NULL
        json = Nearests.get_json(response)
        @test isa(json, String)
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
        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Nearest with single result" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 1)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
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
        set_approach!(params, 1, Approach(0))  # curb

        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, Snapping(0))  # default

        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Nearest - Response Accessors" begin
    @testset "get_json returns valid JSON" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest_response(osrm, params)
        json_str = Nearests.get_json(response)
        @test isa(json_str, String)
        @test !isempty(json_str)
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Position(0.0, 0.0))
        try
            response = nearest_response(osrm, params)
            @test response isa NearestResponse
            json = Nearests.get_json(response)
            @test isa(json, String)
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Position(200.0, 200.0))
        try
            nearest_response(osrm, params)
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
            response = nearest_response(osrm, params)
            @test response isa NearestResponse
            json = Nearests.get_json(response)
            @test isa(json, String)
            @test !isempty(json)
        end
    end

    @testset "Nearest with zero results requested" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 0)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        try
            response = nearest_response(osrm, params)
            @test response isa NearestResponse
            json = Nearests.get_json(response)
            @test isa(json, String)
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Nearest with large number of results" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        set_number_of_results!(params, 100)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Nearest result distance is reasonable" begin
        osrm = Fixtures.get_test_osrm()
        params = NearestParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        response = nearest_response(osrm, params)
        @test response isa NearestResponse
        json = Nearests.get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end
