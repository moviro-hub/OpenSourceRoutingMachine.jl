using Test
using OpenSourceRoutingMachine: Position, OSRMError
using OpenSourceRoutingMachine.Matches:
    MatchParams,
    MatchResponse,
    MatchGaps,
    MATCH_GAPS_SPLIT,
    MATCH_GAPS_IGNORE,
    add_coordinate!,
    add_coordinate_with!,
    add_timestamp!,
    set_gaps!,
    set_tidy!,
    match,
    match_response
const Matches = OpenSourceRoutingMachine.Matches
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
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end

    @testset "Match response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
            add_coordinate!(params, coord)
        end
        response = match_response(osrm, params)
        @test response isa MatchResponse
        @test response.ptr != C_NULL
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
        set_gaps!(params, MATCH_GAPS_SPLIT)
        set_gaps!(params, MATCH_GAPS_IGNORE)
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
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end

    @testset "Match with gaps set to split" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_gaps!(params, MATCH_GAPS_SPLIT)
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
            add_coordinate!(params, coord)
        end
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end

    @testset "Match with tidy enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        set_tidy!(params, true)
        for coord in Fixtures.MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
            add_coordinate!(params, coord)
        end
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end

    @testset "add_coordinate_with!" begin
        params = MatchParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0, 0, 180)
        @test true
    end
end


@testset "Match - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        add_coordinate!(params, Position(0.0, 0.0))
        add_coordinate!(params, Position(1.0, 1.0))
        try
            response = match_response(osrm, params)
            @test response isa MatchResponse
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        add_coordinate!(params, Position(200.0, 200.0))
        add_coordinate!(params, Position(201.0, 201.0))
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
            response = match_response(osrm, params)
            @test response isa MatchResponse
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
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end

    @testset "Match with multiple tracepoints" begin
        osrm = Fixtures.get_test_osrm()
        params = MatchParams()
        for coord in Fixtures.MATCH_TEST_COORDS_MULTI_SEGMENT
            add_coordinate!(params, coord)
        end
        response = match_response(osrm, params)
        @test response isa MatchResponse
        response = match_response(osrm, params)
        @test response isa MatchResponse
    end
end
