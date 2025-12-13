using Test
using OpenSourceRoutingMachine: Position, OSRMError
using OpenSourceRoutingMachine: Snapping, Approach, approach_curb, snapping_default
using OpenSourceRoutingMachine.Tables:
    TableParams,
    TableResponse,
    TableAnnotations,
    TableFallbackCoordinate,
    table_annotations_all,
    table_fallback_coordinate_input,
    add_coordinate!,
    add_coordinate_with!,
    add_source!,
    add_destination!,
    set_annotations!,
    set_fallback_speed!,
    set_fallback_coordinate_type!,
    set_scale_factor!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!,
    table,
    table_response,
    get_json
using Base: C_NULL, size, length, isfinite, isapprox
using .Fixtures

@testset "Table - Basic" begin
    @testset "TableParams creation" begin
        params = TableParams()
        @test params isa TableParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = TableParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Many-to-many table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        coords = Fixtures.hamburg_coordinates()
        for coord in coords
            add_coordinate!(params, coord)
        end
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Specific sources and destinations" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        add_source!(params, 2)
        add_destination!(params, 3)
        add_destination!(params, 4)
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Table - Parameters" begin
    @testset "Additional parameter helpers smoke test" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()

        # coordinates
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate_with!(params, Fixtures.HAMBURG_AIRPORT, 10.0, 0, 180)

        # table-specific knobs
        set_annotations!(params, table_annotations_all)
        set_fallback_speed!(params, 50.0)
        set_fallback_coordinate_type!(params, table_fallback_coordinate_input)
        set_scale_factor!(params, 1.0)

        # generic per-coordinate helpers
        set_hint!(params, 1, "")
        set_radius!(params, 1, 5.0)
        set_bearing!(params, 1, 0, 90)
        set_approach!(params, 1, approach_curb)

        # generic global helpers
        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, snapping_default)

        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Table - Error Handling" begin
    @testset "Invalid table request" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, Position(200.0, 91.0))
        @test_throws OSRMError table(osrm, params)
    end

    @testset "Table with single coordinate" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        set_annotations!(params, table_annotations_all)
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Table - Edge Cases" begin
    @testset "Large table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        base_lat = 53.55
        base_lon = 9.99
        n = 5
        for i in 1:n
            for j in 1:n
                add_coordinate!(params, Position(base_lon + (j - 3) * 0.01, base_lat + (i - 3) * 0.01))
            end
        end
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "One-to-many table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Many-to-one table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_destination!(params, 1)
        response = table_response(osrm, params)
        @test response isa TableResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "JSON output" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = table_response(osrm, params)
        json_str = get_json(response)
        @test json_str isa String
        @test !isempty(json_str)
        @test occursin("durations", json_str) || occursin("distances", json_str)
    end
end
