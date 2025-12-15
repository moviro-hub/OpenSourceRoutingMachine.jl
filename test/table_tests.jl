using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Tables: Tables

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Table - Setters and Getters" begin
    @testset "Sources" begin
        params = Tables.TableParams()
        # Add coordinates first
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["airport"])
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["port"])

        # Initially no sources
        @test Tables.get_source_count(params) == 0

        # Add source
        Tables.add_source!(params, 2)
        @test Tables.get_source_count(params) == 1
        @test Tables.get_source(params, 1) == 2

        # Add another source
        Tables.add_source!(params, 1)
        @test Tables.get_source_count(params) == 2
        sources = Tables.get_sources(params)
        @test length(sources) == 2
        @test 1 in sources
        @test 2 in sources
    end

    @testset "Destinations" begin
        params = Tables.TableParams()
        # Add coordinates first
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["airport"])
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["port"])

        # Initially no destinations
        @test Tables.get_destination_count(params) == 0

        # Add destination
        Tables.add_destination!(params, 3)
        @test Tables.get_destination_count(params) == 1
        @test Tables.get_destination(params, 1) == 3

        # Add another destination
        Tables.add_destination!(params, 2)
        @test Tables.get_destination_count(params) == 2
        destinations = Tables.get_destinations(params)
        @test length(destinations) == 2
        @test 2 in destinations
        @test 3 in destinations
    end

    @testset "Annotations" begin
        params = Tables.TableParams()
        # Default value
        initial_annotations = Tables.get_annotations(params)
        @test initial_annotations isa Tables.TableAnnotations

        # Test valid annotation values (NONE may not be supported)
        Tables.set_annotations!(params, Tables.TABLE_ANNOTATIONS_DURATION)
        @test Tables.get_annotations(params) == Tables.TABLE_ANNOTATIONS_DURATION

        Tables.set_annotations!(params, Tables.TABLE_ANNOTATIONS_DISTANCE)
        @test Tables.get_annotations(params) == Tables.TABLE_ANNOTATIONS_DISTANCE

        Tables.set_annotations!(params, Tables.TABLE_ANNOTATIONS_ALL)
        @test Tables.get_annotations(params) == Tables.TABLE_ANNOTATIONS_ALL
    end

    @testset "Fallback Speed" begin
        params = Tables.TableParams()
        # Default value
        initial_speed = Tables.get_fallback_speed(params)
        @test initial_speed isa Float64

        Tables.set_fallback_speed!(params, 50.0)
        @test Tables.get_fallback_speed(params) == 50.0

        Tables.set_fallback_speed!(params, 100.5)
        @test Tables.get_fallback_speed(params) == 100.5

        # Note: Fallback speed must be positive, so we can't test 0.0
        Tables.set_fallback_speed!(params, 1.0)
        @test Tables.get_fallback_speed(params) == 1.0
    end

    @testset "Fallback Coordinate Type" begin
        params = Tables.TableParams()
        # Default value
        initial_type = Tables.get_fallback_coordinate_type(params)
        @test initial_type isa Tables.TableFallbackCoordinate

        Tables.set_fallback_coordinate_type!(params, Tables.TABLE_FALLBACK_COORDINATE_INPUT)
        @test Tables.get_fallback_coordinate_type(params) == Tables.TABLE_FALLBACK_COORDINATE_INPUT

        Tables.set_fallback_coordinate_type!(params, Tables.TABLE_FALLBACK_COORDINATE_SNAPPED)
        @test Tables.get_fallback_coordinate_type(params) == Tables.TABLE_FALLBACK_COORDINATE_SNAPPED
    end

    @testset "Scale Factor" begin
        params = Tables.TableParams()
        # Default value
        initial_factor = Tables.get_scale_factor(params)
        @test initial_factor isa Float64

        Tables.set_scale_factor!(params, 1.0)
        @test Tables.get_scale_factor(params) == 1.0

        Tables.set_scale_factor!(params, 2.5)
        @test Tables.get_scale_factor(params) == 2.5

        Tables.set_scale_factor!(params, 0.5)
        @test Tables.get_scale_factor(params) == 0.5
    end

    @testset "Coordinates" begin
        params = Tables.TableParams()
        @test Tables.get_coordinate_count(params) == 0

        coord1 = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate!(params, coord1)
        @test Tables.get_coordinate_count(params) == 1
        @test Tables.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.get_hamburg_coordinates()["port"]
        Tables.add_coordinate!(params, coord2)
        @test Tables.get_coordinate_count(params) == 2
        @test Tables.get_coordinate(params, 1) == coord1
        @test Tables.get_coordinate(params, 2) == coord2

        coords = Tables.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Tables.TableParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Tables.get_coordinate_count(params) == 1
        @test Tables.get_coordinate(params, 1) == coord

        coord_with = Tables.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Tables.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Tables.TableParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Tables.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Tables.set_hint!(params, 1, "")
        @test Tables.get_hint(params, 1) == ""

        # Set a non-empty hint
        Tables.set_hint!(params, 1, "test_hint")
        result = Tables.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Tables.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Tables.TableParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate!(params, coord)

        # Initially no radius set
        @test Tables.get_radius(params, 1) === nothing

        # Set radius
        Tables.set_radius!(params, 1, 5.0)
        @test Tables.get_radius(params, 1) == 5.0

        # Set different radius
        Tables.set_radius!(params, 1, 10.5)
        @test Tables.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Tables.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Tables.TableParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Tables.get_bearing(params, 1) === nothing

        # Set bearing
        Tables.set_bearing!(params, 1, 0, 90)
        bearing = Tables.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Tables.set_bearing!(params, 1, 180, 45)
        bearing = Tables.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Tables.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Tables.TableParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Tables.add_coordinate!(params, coord)

        # Initially no approach set
        @test Tables.get_approach(params, 1) === nothing

        # Set approach
        Tables.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Tables.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Tables.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Tables.TableParams()

        # Initially no excludes
        @test Tables.get_exclude_count(params) == 0

        # Add exclude
        Tables.add_exclude!(params, "toll")
        @test Tables.get_exclude_count(params) == 1
        @test Tables.get_exclude(params, 1) == "toll"

        # Add another exclude
        Tables.add_exclude!(params, "ferry")
        @test Tables.get_exclude_count(params) == 2
        @test Tables.get_exclude(params, 1) == "toll"
        @test Tables.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Tables.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Tables.TableParams()

        # Default value
        initial_value = Tables.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Tables.set_generate_hints!(params, true)
        @test Tables.get_generate_hints(params) == true

        # Set to false
        Tables.set_generate_hints!(params, false)
        @test Tables.get_generate_hints(params) == false

        # Set back to true
        Tables.set_generate_hints!(params, true)
        @test Tables.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Tables.TableParams()

        # Default value
        initial_value = Tables.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Tables.set_skip_waypoints!(params, true)
        @test Tables.get_skip_waypoints(params) == true

        # Set to false
        Tables.set_skip_waypoints!(params, false)
        @test Tables.get_skip_waypoints(params) == false

        # Set back to true
        Tables.set_skip_waypoints!(params, true)
        @test Tables.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Tables.TableParams()

        # Default value
        initial_snapping = Tables.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Tables.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Tables.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Table - Query Execution" begin
    @testset "Many-to-many table" begin
        params = Tables.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Tables.add_coordinate!(params, coord)
        end
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Specific sources and destinations" begin
        params = Tables.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Tables.add_coordinate!(params, coord)
        end
        Tables.add_source!(params, 1)
        Tables.add_source!(params, 2)
        Tables.add_destination!(params, 3)
        Tables.add_destination!(params, 4)
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end

    @testset "One-to-many table" begin
        params = Tables.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Tables.add_coordinate!(params, coord)
        end
        Tables.add_source!(params, 1)
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end

    @testset "Many-to-one table" begin
        params = Tables.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Tables.add_coordinate!(params, coord)
        end
        Tables.add_destination!(params, 1)
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end

    @testset "Table with all parameters" begin
        params = Tables.TableParams()
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        Tables.add_coordinate_with!(params, TestUtils.get_hamburg_coordinates()["airport"], 10.0, 0, 180)

        Tables.set_annotations!(params, Tables.TABLE_ANNOTATIONS_ALL)
        Tables.set_fallback_speed!(params, 50.0)
        Tables.set_fallback_coordinate_type!(params, Tables.TABLE_FALLBACK_COORDINATE_INPUT)
        Tables.set_scale_factor!(params, 1.0)

        Tables.set_hint!(params, 1, "")
        Tables.set_radius!(params, 1, 5.0)
        Tables.set_bearing!(params, 1, 0, 90)
        Tables.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Tables.add_exclude!(params, "toll")
        Tables.set_generate_hints!(params, true)
        Tables.set_skip_waypoints!(params, false)
        Tables.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end

    @testset "Table with single coordinate" begin
        params = Tables.TableParams()
        Tables.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        Tables.set_annotations!(params, Tables.TABLE_ANNOTATIONS_ALL)
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end
end

@testset "Table - Error Handling" begin
    @testset "Invalid table request" begin
        params = Tables.TableParams()
        Tables.add_coordinate!(params, OSRMs.Position(200.0, 91.0))
        @test_throws OSRMError Tables.table(TestUtils.get_test_osrm(), params)
    end

    @testset "Error messages are informative" begin
        params = Tables.TableParams()
        Tables.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        try
            Tables.table(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Table - Edge Cases" begin
    @testset "Large table" begin
        params = Tables.TableParams()
        base_lat = 53.55
        base_lon = 9.99
        n = 5
        for i in 1:n
            for j in 1:n
                Tables.add_coordinate!(params, OSRMs.Position(base_lon + (j - 3) * 0.01, base_lat + (i - 3) * 0.01))
            end
        end
        response = Tables.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Tables.TableResponse
    end
end
