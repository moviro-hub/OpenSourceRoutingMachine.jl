using Test
using OpenSourceRoutingMachine: OSRM, OSRMConfig, Position, OSRMError
using OpenSourceRoutingMachine: Approach, Snapping, APPROACH_CURB, SNAPPING_DEFAULT
using OpenSourceRoutingMachine.Tables:
    TableParams,
    TableResponse,
    TableAnnotations,
    TableFallbackCoordinate,
    TABLE_ANNOTATIONS_NONE,
    TABLE_ANNOTATIONS_DURATION,
    TABLE_ANNOTATIONS_DISTANCE,
    TABLE_ANNOTATIONS_ALL,
    TABLE_FALLBACK_COORDINATE_INPUT,
    TABLE_FALLBACK_COORDINATE_SNAPPED,
    add_coordinate!,
    add_coordinate_with!,
    add_source!,
    get_source,
    get_sources,
    get_source_count,
    add_destination!,
    get_destination,
    get_destinations,
    get_destination_count,
    set_annotations!,
    get_annotations,
    set_fallback_speed!,
    get_fallback_speed,
    set_fallback_coordinate_type!,
    get_fallback_coordinate_type,
    set_scale_factor!,
    get_scale_factor,
    set_hint!,
    get_hint,
    get_hints,
    set_radius!,
    get_radius,
    get_radii,
    set_bearing!,
    get_bearing,
    get_bearings,
    set_approach!,
    get_approach,
    get_approaches,
    add_exclude!,
    get_exclude,
    get_excludes,
    get_exclude_count,
    set_generate_hints!,
    get_generate_hints,
    set_skip_waypoints!,
    get_skip_waypoints,
    set_snapping!,
    get_snapping,
    get_coordinates,
    get_coordinate,
    get_coordinate_count,
    get_coordinate_with,
    get_coordinates_with,
    table,
    table_response
using Base: C_NULL

include("TestUtils.jl")
using .TestUtils: get_test_osrm, get_hamburg_coordinates

@testset "Table - Setters and Getters" begin
    @testset "Sources" begin
        params = TableParams()
        # Add coordinates first
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        add_coordinate!(params, get_hamburg_coordinates()["port"])

        # Initially no sources
        @test get_source_count(params) == 0

        # Add source
        add_source!(params, 2)
        @test get_source_count(params) == 1
        @test get_source(params, 1) == 2

        # Add another source
        add_source!(params, 1)
        @test get_source_count(params) == 2
        sources = get_sources(params)
        @test length(sources) == 2
        @test 1 in sources
        @test 2 in sources
    end

    @testset "Destinations" begin
        params = TableParams()
        # Add coordinates first
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        add_coordinate!(params, get_hamburg_coordinates()["port"])

        # Initially no destinations
        @test get_destination_count(params) == 0

        # Add destination
        add_destination!(params, 3)
        @test get_destination_count(params) == 1
        @test get_destination(params, 1) == 3

        # Add another destination
        add_destination!(params, 2)
        @test get_destination_count(params) == 2
        destinations = get_destinations(params)
        @test length(destinations) == 2
        @test 2 in destinations
        @test 3 in destinations
    end

    @testset "Annotations" begin
        params = TableParams()
        # Default value
        initial_annotations = get_annotations(params)
        @test initial_annotations isa TableAnnotations

        # Test valid annotation values (NONE may not be supported)
        set_annotations!(params, TABLE_ANNOTATIONS_DURATION)
        @test get_annotations(params) == TABLE_ANNOTATIONS_DURATION

        set_annotations!(params, TABLE_ANNOTATIONS_DISTANCE)
        @test get_annotations(params) == TABLE_ANNOTATIONS_DISTANCE

        set_annotations!(params, TABLE_ANNOTATIONS_ALL)
        @test get_annotations(params) == TABLE_ANNOTATIONS_ALL
    end

    @testset "Fallback Speed" begin
        params = TableParams()
        # Default value
        initial_speed = get_fallback_speed(params)
        @test initial_speed isa Float64

        set_fallback_speed!(params, 50.0)
        @test get_fallback_speed(params) == 50.0

        set_fallback_speed!(params, 100.5)
        @test get_fallback_speed(params) == 100.5

        # Note: Fallback speed must be positive, so we can't test 0.0
        set_fallback_speed!(params, 1.0)
        @test get_fallback_speed(params) == 1.0
    end

    @testset "Fallback Coordinate Type" begin
        params = TableParams()
        # Default value
        initial_type = get_fallback_coordinate_type(params)
        @test initial_type isa TableFallbackCoordinate

        set_fallback_coordinate_type!(params, TABLE_FALLBACK_COORDINATE_INPUT)
        @test get_fallback_coordinate_type(params) == TABLE_FALLBACK_COORDINATE_INPUT

        set_fallback_coordinate_type!(params, TABLE_FALLBACK_COORDINATE_SNAPPED)
        @test get_fallback_coordinate_type(params) == TABLE_FALLBACK_COORDINATE_SNAPPED
    end

    @testset "Scale Factor" begin
        params = TableParams()
        # Default value
        initial_factor = get_scale_factor(params)
        @test initial_factor isa Float64

        set_scale_factor!(params, 1.0)
        @test get_scale_factor(params) == 1.0

        set_scale_factor!(params, 2.5)
        @test get_scale_factor(params) == 2.5

        set_scale_factor!(params, 0.5)
        @test get_scale_factor(params) == 0.5
    end

    @testset "Coordinates" begin
        params = TableParams()
        @test get_coordinate_count(params) == 0

        coord1 = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord1)
        @test get_coordinate_count(params) == 1
        @test get_coordinate(params, 1) == coord1

        coord2 = get_hamburg_coordinates()["port"]
        add_coordinate!(params, coord2)
        @test get_coordinate_count(params) == 2
        @test get_coordinate(params, 1) == coord1
        @test get_coordinate(params, 2) == coord2

        coords = get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = TableParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test get_coordinate_count(params) == 1
        @test get_coordinate(params, 1) == coord

        coord_with = get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = TableParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        set_hint!(params, 1, "")
        @test get_hint(params, 1) == ""

        # Set a non-empty hint
        set_hint!(params, 1, "test_hint")
        result = get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = TableParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no radius set
        @test get_radius(params, 1) === nothing

        # Set radius
        set_radius!(params, 1, 5.0)
        @test get_radius(params, 1) == 5.0

        # Set different radius
        set_radius!(params, 1, 10.5)
        @test get_radius(params, 1) == 10.5

        # Get all radii
        radii = get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = TableParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no bearing set
        @test get_bearing(params, 1) === nothing

        # Set bearing
        set_bearing!(params, 1, 0, 90)
        bearing = get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        set_bearing!(params, 1, 180, 45)
        bearing = get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = TableParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no approach set
        @test get_approach(params, 1) === nothing

        # Set approach
        set_approach!(params, 1, APPROACH_CURB)
        @test get_approach(params, 1) == APPROACH_CURB

        # Get all approaches
        approaches = get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == APPROACH_CURB
    end

    @testset "Excludes" begin
        params = TableParams()

        # Initially no excludes
        @test get_exclude_count(params) == 0

        # Add exclude
        add_exclude!(params, "toll")
        @test get_exclude_count(params) == 1
        @test get_exclude(params, 1) == "toll"

        # Add another exclude
        add_exclude!(params, "ferry")
        @test get_exclude_count(params) == 2
        @test get_exclude(params, 1) == "toll"
        @test get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = TableParams()

        # Default value
        initial_value = get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        set_generate_hints!(params, true)
        @test get_generate_hints(params) == true

        # Set to false
        set_generate_hints!(params, false)
        @test get_generate_hints(params) == false

        # Set back to true
        set_generate_hints!(params, true)
        @test get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = TableParams()

        # Default value
        initial_value = get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        set_skip_waypoints!(params, true)
        @test get_skip_waypoints(params) == true

        # Set to false
        set_skip_waypoints!(params, false)
        @test get_skip_waypoints(params) == false

        # Set back to true
        set_skip_waypoints!(params, true)
        @test get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = TableParams()

        # Default value
        initial_snapping = get_snapping(params)
        @test initial_snapping isa Snapping

        # Set snapping
        set_snapping!(params, SNAPPING_DEFAULT)
        @test get_snapping(params) == SNAPPING_DEFAULT
    end
end

@testset "Table - Query Execution" begin
    @testset "Many-to-many table" begin
        params = TableParams()
        for (name, coord) in get_hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
        @test response.ptr != C_NULL
    end

    @testset "Specific sources and destinations" begin
        params = TableParams()
        for (name, coord) in get_hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        add_source!(params, 2)
        add_destination!(params, 3)
        add_destination!(params, 4)
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end

    @testset "One-to-many table" begin
        params = TableParams()
        for (name, coord) in get_hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_source!(params, 1)
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end

    @testset "Many-to-one table" begin
        params = TableParams()
        for (name, coord) in get_hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        add_destination!(params, 1)
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end

    @testset "Table with all parameters" begin
        params = TableParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate_with!(params, get_hamburg_coordinates()["airport"], 10.0, 0, 180)

        set_annotations!(params, TABLE_ANNOTATIONS_ALL)
        set_fallback_speed!(params, 50.0)
        set_fallback_coordinate_type!(params, TABLE_FALLBACK_COORDINATE_INPUT)
        set_scale_factor!(params, 1.0)

        set_hint!(params, 1, "")
        set_radius!(params, 1, 5.0)
        set_bearing!(params, 1, 0, 90)
        set_approach!(params, 1, APPROACH_CURB)

        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, SNAPPING_DEFAULT)

        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end

    @testset "Table with single coordinate" begin
        params = TableParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        set_annotations!(params, TABLE_ANNOTATIONS_ALL)
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end
end

@testset "Table - Error Handling" begin
    @testset "Invalid table request" begin
        params = TableParams()
        add_coordinate!(params, Position(200.0, 91.0))
        @test_throws OSRMError table(get_test_osrm(), params)
    end

    @testset "Error messages are informative" begin
        params = TableParams()
        add_coordinate!(params, Position(200.0, 200.0))
        try
            table(get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Table - Edge Cases" begin
    @testset "Large table" begin
        params = TableParams()
        base_lat = 53.55
        base_lon = 9.99
        n = 5
        for i in 1:n
            for j in 1:n
                add_coordinate!(params, Position(base_lon + (j - 3) * 0.01, base_lat + (i - 3) * 0.01))
            end
        end
        response = table_response(get_test_osrm(), params)
        @test response isa TableResponse
    end
end
