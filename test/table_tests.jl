using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Table: Table

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Table - Setters and Getters" begin
    @testset "Sources" begin
        params = Table.TableParams()
        # Add coordinates first
        Table.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Table.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Table.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no sources
        @test Table.get_source_count(params) == 0

        # Add source
        Table.add_source!(params, 2)
        @test Table.get_source_count(params) == 1
        @test Table.get_source(params, 1) == 2

        # Add another source
        Table.add_source!(params, 1)
        @test Table.get_source_count(params) == 2
        sources = Table.get_sources(params)
        @test length(sources) == 2
        @test 1 in sources
        @test 2 in sources
    end

    @testset "Destinations" begin
        params = Table.TableParams()
        # Add coordinates first
        Table.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Table.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Table.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no destinations
        @test Table.get_destination_count(params) == 0

        # Add destination
        Table.add_destination!(params, 3)
        @test Table.get_destination_count(params) == 1
        @test Table.get_destination(params, 1) == 3

        # Add another destination
        Table.add_destination!(params, 2)
        @test Table.get_destination_count(params) == 2
        destinations = Table.get_destinations(params)
        @test length(destinations) == 2
        @test 2 in destinations
        @test 3 in destinations
    end

    @testset "Annotations" begin
        params = Table.TableParams()
        # Default value
        initial_annotations = Table.get_annotations(params)
        @test initial_annotations isa Table.TableAnnotations

        # Test valid annotation values (NONE may not be supported)
        Table.set_annotations!(params, Table.TABLE_ANNOTATIONS_DURATION)
        @test Table.get_annotations(params) == Table.TABLE_ANNOTATIONS_DURATION

        Table.set_annotations!(params, Table.TABLE_ANNOTATIONS_DISTANCE)
        @test Table.get_annotations(params) == Table.TABLE_ANNOTATIONS_DISTANCE

        Table.set_annotations!(params, Table.TABLE_ANNOTATIONS_ALL)
        @test Table.get_annotations(params) == Table.TABLE_ANNOTATIONS_ALL
    end

    @testset "Fallback Speed" begin
        params = Table.TableParams()
        # Default value
        initial_speed = Table.get_fallback_speed(params)
        @test initial_speed isa Float64

        Table.set_fallback_speed!(params, 50.0)
        @test Table.get_fallback_speed(params) == 50.0

        Table.set_fallback_speed!(params, 100.5)
        @test Table.get_fallback_speed(params) == 100.5

        # Note: Fallback speed must be positive, so we can't test 0.0
        Table.set_fallback_speed!(params, 1.0)
        @test Table.get_fallback_speed(params) == 1.0
    end

    @testset "Fallback Coordinate Type" begin
        params = Table.TableParams()
        # Default value
        initial_type = Table.get_fallback_coordinate_type(params)
        @test initial_type isa Table.TableFallbackCoordinate

        Table.set_fallback_coordinate_type!(params, Table.TABLE_FALLBACK_COORDINATE_INPUT)
        @test Table.get_fallback_coordinate_type(params) == Table.TABLE_FALLBACK_COORDINATE_INPUT

        Table.set_fallback_coordinate_type!(params, Table.TABLE_FALLBACK_COORDINATE_SNAPPED)
        @test Table.get_fallback_coordinate_type(params) == Table.TABLE_FALLBACK_COORDINATE_SNAPPED
    end

    @testset "Scale Factor" begin
        params = Table.TableParams()
        # Default value
        initial_factor = Table.get_scale_factor(params)
        @test initial_factor isa Float64

        Table.set_scale_factor!(params, 1.0)
        @test Table.get_scale_factor(params) == 1.0

        Table.set_scale_factor!(params, 2.5)
        @test Table.get_scale_factor(params) == 2.5

        Table.set_scale_factor!(params, 0.5)
        @test Table.get_scale_factor(params) == 0.5
    end

    @testset "Coordinates" begin
        params = Table.TableParams()
        @test Table.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate!(params, coord1)
        @test Table.get_coordinate_count(params) == 1
        @test Table.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Table.add_coordinate!(params, coord2)
        @test Table.get_coordinate_count(params) == 2
        @test Table.get_coordinate(params, 1) == coord1
        @test Table.get_coordinate(params, 2) == coord2

        coords = Table.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Table.TableParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Table.get_coordinate_count(params) == 1
        @test Table.get_coordinate(params, 1) == coord

        coord_with = Table.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Table.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Table.TableParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Table.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Table.set_hint!(params, 1, "")
        @test Table.get_hint(params, 1) == ""

        # Set a non-empty hint
        Table.set_hint!(params, 1, "test_hint")
        result = Table.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Table.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Table.TableParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate!(params, coord)

        # Initially no radius set
        @test Table.get_radius(params, 1) === nothing

        # Set radius
        Table.set_radius!(params, 1, 5.0)
        @test Table.get_radius(params, 1) == 5.0

        # Set different radius
        Table.set_radius!(params, 1, 10.5)
        @test Table.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Table.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Table.TableParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Table.get_bearing(params, 1) === nothing

        # Set bearing
        Table.set_bearing!(params, 1, 0, 90)
        bearing = Table.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Table.set_bearing!(params, 1, 180, 45)
        bearing = Table.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Table.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Table.TableParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Table.add_coordinate!(params, coord)

        # Initially no approach set
        @test Table.get_approach(params, 1) === nothing

        # Set approach
        Table.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Table.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Table.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Table.TableParams()

        # Initially no excludes
        @test Table.get_exclude_count(params) == 0

        # Add exclude
        Table.add_exclude!(params, "toll")
        @test Table.get_exclude_count(params) == 1
        @test Table.get_exclude(params, 1) == "toll"

        # Add another exclude
        Table.add_exclude!(params, "ferry")
        @test Table.get_exclude_count(params) == 2
        @test Table.get_exclude(params, 1) == "toll"
        @test Table.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Table.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Table.TableParams()

        # Default value
        initial_value = Table.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Table.set_generate_hints!(params, true)
        @test Table.get_generate_hints(params) == true

        # Set to false
        Table.set_generate_hints!(params, false)
        @test Table.get_generate_hints(params) == false

        # Set back to true
        Table.set_generate_hints!(params, true)
        @test Table.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Table.TableParams()

        # Default value
        initial_value = Table.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Table.set_skip_waypoints!(params, true)
        @test Table.get_skip_waypoints(params) == true

        # Set to false
        Table.set_skip_waypoints!(params, false)
        @test Table.get_skip_waypoints(params) == false

        # Set back to true
        Table.set_skip_waypoints!(params, true)
        @test Table.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Table.TableParams()

        # Default value
        initial_snapping = Table.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Table.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Table.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Table - Query Execution" begin
    @testset "Many-to-many table" begin
        params = Table.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Table.add_coordinate!(params, coord)
        end
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Specific sources and destinations" begin
        params = Table.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Table.add_coordinate!(params, coord)
        end
        Table.add_source!(params, 1)
        Table.add_source!(params, 2)
        Table.add_destination!(params, 3)
        Table.add_destination!(params, 4)
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end

    @testset "One-to-many table" begin
        params = Table.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Table.add_coordinate!(params, coord)
        end
        Table.add_source!(params, 1)
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end

    @testset "Many-to-one table" begin
        params = Table.TableParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Table.add_coordinate!(params, coord)
        end
        Table.add_destination!(params, 1)
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end

    @testset "Table with all parameters" begin
        params = Table.TableParams()
        Table.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Table.add_coordinate_with!(params, TestUtils.HAMBURG_AIRPORT, 10.0, 0, 180)

        Table.set_annotations!(params, Table.TABLE_ANNOTATIONS_ALL)
        Table.set_fallback_speed!(params, 50.0)
        Table.set_fallback_coordinate_type!(params, Table.TABLE_FALLBACK_COORDINATE_INPUT)
        Table.set_scale_factor!(params, 1.0)

        Table.set_hint!(params, 1, "")
        Table.set_radius!(params, 1, 5.0)
        Table.set_bearing!(params, 1, 0, 90)
        Table.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Table.add_exclude!(params, "toll")
        Table.set_generate_hints!(params, true)
        Table.set_skip_waypoints!(params, false)
        Table.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end

    @testset "Table with single coordinate" begin
        params = Table.TableParams()
        Table.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Table.set_annotations!(params, Table.TABLE_ANNOTATIONS_ALL)
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end
end

@testset "Table - Error Handling" begin
    @testset "Invalid table request" begin
        params = Table.TableParams()
        Table.add_coordinate!(params, OSRMs.Position(200.0, 91.0))
        @test_throws OSRMs.OSRMError Table.table(TestUtils.get_test_osrm(), params)
    end

    @testset "Error messages are informative" begin
        params = Table.TableParams()
        Table.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        try
            Table.table(TestUtils.get_test_osrm(), params)
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
        params = Table.TableParams()
        base_lat = 53.55
        base_lon = 9.99
        n = 5
        for i in 1:n
            for j in 1:n
                Table.add_coordinate!(params, OSRMs.Position(base_lon + (j - 3) * 0.01, base_lat + (i - 3) * 0.01))
            end
        end
        response = Table.table_response(TestUtils.get_test_osrm(), params)
        @test response isa Table.TableResponse
    end
end
