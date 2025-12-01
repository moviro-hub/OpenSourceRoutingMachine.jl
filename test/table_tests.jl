using Test
using OpenSourceRoutingMachine: LatLon, OSRMError
using OpenSourceRoutingMachine: Snapping, Approach
using OpenSourceRoutingMachine.Tables:
    TableParams,
    TableResponse,
    add_coordinate!,
    add_coordinate_with!,
    add_source!,
    add_destination!,
    set_annotations_mask!,
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
    source_count,
    destination_count,
    as_json,
    duration_matrix,
    distance_matrix,
    duration,
    distance
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
        response = table(osrm, params)
        @test response isa TableResponse
        @test source_count(response) == length(coords)
        @test destination_count(response) == length(coords)
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
        response = table(osrm, params)
        @test source_count(response) == 2
        @test destination_count(response) == 2
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
        set_annotations_mask!(params, "distance,duration")
        set_fallback_speed!(params, 50.0)
        set_fallback_coordinate_type!(params, "input")
        set_scale_factor!(params, 1.0)

        # generic per-coordinate helpers
        set_hint!(params, 1, "")
        set_radius!(params, 1, 5.0)
        set_bearing!(params, 1, 0, 90)
        set_approach!(params, 1, Approach.curb)

        # generic global helpers
        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, Snapping.default)

        response = table(osrm, params)
        @test response isa TableResponse
        @test source_count(response) >= 1
        @test destination_count(response) >= 1
    end
end

@testset "Table - Response Accessors" begin
    @testset "Duration and distance accessors" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT, Fixtures.HAMBURG_PORT]
            add_coordinate!(params, coord)
        end
        set_annotations_mask!(params, "distance,duration")
        response = table(osrm, params)
        @test duration(response, 1, 1) == 0.0
        @test distance(response, 1, 1) == 0.0
        @test duration(response, 1, 2) > 0.0
        @test distance(response, 1, 2) > 0.0
        @test isfinite(duration(response, 1, 2))
        @test isfinite(distance(response, 1, 2))
    end

    @testset "Source and destination counts" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = table(osrm, params)
        @test source_count(response) == 4
        @test destination_count(response) == 4
    end

    @testset "Asymmetric table counts" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        add_source!(params, 2)
        add_destination!(params, 2)
        add_destination!(params, 3)
        add_destination!(params, 4)
        response = table(osrm, params)
        @test source_count(response) == 2
        @test destination_count(response) == 3
    end
end

@testset "Table - Matrix Operations" begin
    @testset "Duration matrix" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT, Fixtures.HAMBURG_PORT]
            add_coordinate!(params, coord)
        end
        set_annotations_mask!(params, "distance,duration")
        response = table(osrm, params)
        dur_matrix = duration_matrix(response)
        @test size(dur_matrix) == (3, 3)
        @test dur_matrix[1, 1] == 0.0
        @test dur_matrix[2, 2] == 0.0
        @test dur_matrix[3, 3] == 0.0
        @test dur_matrix[1, 2] > 0.0
        @test dur_matrix[1, 3] > 0.0
        @test all(isfinite, dur_matrix)
    end

    @testset "Distance matrix" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT]
            add_coordinate!(params, coord)
        end
        set_annotations_mask!(params, "distance,duration")
        response = table(osrm, params)
        dist_matrix = distance_matrix(response)
        @test size(dist_matrix) == (2, 2)
        @test dist_matrix[1, 1] == 0.0
        @test dist_matrix[2, 2] == 0.0
        @test dist_matrix[1, 2] > 0.0
        @test all(isfinite, dist_matrix)
    end

    @testset "Matrix consistency with accessors" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        set_annotations_mask!(params, "distance,duration")
        response = table(osrm, params)
        dur_matrix = duration_matrix(response)
        dist_matrix = distance_matrix(response)
        for i in 1:source_count(response)
            for j in 1:destination_count(response)
                if dur_matrix[i, j] == 0.0 && duration(response, i, j) == 0.0
                    @test true
                else
                    @test isapprox(dur_matrix[i, j], duration(response, i, j), rtol = 1.0e-5)
                end
                if dist_matrix[i, j] == 0.0 && distance(response, i, j) == 0.0
                    @test true
                else
                    @test isapprox(dist_matrix[i, j], distance(response, i, j), rtol = 1.0e-5)
                end
            end
        end
    end
end

@testset "Table - Error Handling" begin
    @testset "Invalid table request" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, LatLon(91.0, 200.0))
        @test_throws OSRMError table(osrm, params)
    end

    @testset "Table with single coordinate" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        set_annotations_mask!(params, "distance,duration")
        response = table(osrm, params)
        @test source_count(response) == 1
        @test destination_count(response) == 1
        @test duration(response, 1, 1) == 0.0
        @test distance(response, 1, 1) == 0.0
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
                add_coordinate!(params, LatLon(base_lat + (i - 3) * 0.01, base_lon + (j - 3) * 0.01))
            end
        end
        response = table(osrm, params)
        @test source_count(response) == n * n
        @test destination_count(response) == n * n
        dur = duration(response, 1, n * n)
        @test isfinite(dur) || dur == Inf32
    end

    @testset "One-to-many table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        response = table(osrm, params)
        @test source_count(response) == 1
        @test destination_count(response) == 4
    end

    @testset "Many-to-one table" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_destination!(params, 1)
        response = table(osrm, params)
        @test source_count(response) == 4
        @test destination_count(response) == 1
    end

    @testset "JSON output" begin
        osrm = Fixtures.get_test_osrm()
        params = TableParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = table(osrm, params)
        json_str = as_json(response)
        @test json_str isa String
        @test !isempty(json_str)
        @test occursin("durations", json_str) || occursin("distances", json_str)
    end
end
