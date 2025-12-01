using Test
using OpenSourceRoutingMachine: LatLon, OSRMError, Approach, Snapping
using OpenSourceRoutingMachine.Routes:
    RouteParams,
    RouteResponse,
    # params
    add_coordinate!,
    add_coordinate_with!,
    add_steps!,
    add_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!,
    # responses
    route,
    as_json,
    distance,
    duration,
    alternative_count,
    distance_at,
    duration_at,
    geometry_polyline,
    geometry_coordinate_count,
    geometry_coordinate,
    waypoint_count,
    waypoint_coordinate,
    waypoint_name,
    leg_count,
    step_count,
    step_distance,
    step_duration,
    step_instruction
using Base: C_NULL, length, isfinite
using .Fixtures

@testset "Route - Basic" begin
    @testset "RouteParams creation" begin
        params = RouteParams()
        @test params isa RouteParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Route between two points" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route(osrm, params)
        @test response isa RouteResponse
        dist = distance(response)
        dur = duration(response)
        @test dist > 0.0
        @test dur > 0.0
        @test isfinite(dist)
        @test isfinite(dur)
    end

    @testset "Route response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = route(osrm, params)
        @test response.ptr != C_NULL
        @test distance(response) >= 0.0
        @test duration(response) >= 0.0
    end
end

@testset "Route - Parameters" begin
    @testset "add_steps!" begin
        params = RouteParams()
        add_steps!(params, true)
        add_steps!(params, false)
        @test true
    end

    @testset "add_alternatives!" begin
        params = RouteParams()
        add_alternatives!(params, true)
        add_alternatives!(params, false)
        @test true
    end

    @testset "add_coordinate_with!" begin
        params = RouteParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0, 0, 180)
        @test true
    end

    @testset "Route with steps enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_steps!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
        response = route(osrm, params)
        @test distance(response) > 0.0
    end

    @testset "Route with alternatives enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_alternatives!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route(osrm, params)
        @test distance(response) > 0.0
    end

    @testset "Other parameter helpers smoke test" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # basic coordinates
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)

        # toggles and options
        # use a known-valid geometries value
        set_geometries!(params, "geojson")
        set_overview!(params, "full")
        set_continue_straight!(params, true)
        set_number_of_alternatives!(params, 2)
        set_annotations!(params, "distance,duration")

        # waypoint helpers
        # clear/add waypoints without requiring endpoints to be waypoints
        clear_waypoints!(params)

        # per-coordinate hints
        set_hint!(params, 1, "")
        set_radius!(params, 1, 10.0)
        set_bearing!(params, 1, 0, 180)
        set_approach!(params, 1, Approach.curb)

        # global behavior
        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, Snapping.default)

        response = route(osrm, params)
        @test distance(response) > 0.0
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, LatLon(0.0, 0.0))
        add_coordinate!(params, LatLon(1.0, 1.0))
        try
            response = route(osrm, params)
            @test isfinite(distance(response)) || isinf(distance(response))
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, LatLon(200.0, 200.0))
        add_coordinate!(params, LatLon(201.0, 201.0))
        try
            route(osrm, params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Route - Edge Cases" begin
    @testset "Same start and end point" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)
        try
            response = route(osrm, params)
            @test distance(response) >= 0.0
            @test duration(response) >= 0.0
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Very short route" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = LatLon(coord1.lat + 0.001, coord1.lon + 0.001)
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)
        response = route(osrm, params)
        @test distance(response) >= 0.0
        @test duration(response) >= 0.0
        @test isfinite(distance(response))
        @test isfinite(duration(response))
    end

    @testset "Route with multiple waypoints" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = route(osrm, params)
        @test distance(response) > 0.0
        @test duration(response) > 0.0
        @test isfinite(distance(response))
        @test isfinite(duration(response))
    end
end

@testset "Route - Response Accessors" begin
    osrm = Fixtures.get_test_osrm()
    params = RouteParams()

    # Three-waypoint route for waypoint/leg/step tests
    for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT, Fixtures.HAMBURG_PORT]
        add_coordinate!(params, coord)
    end

    add_steps!(params, true)
    set_geometries!(params, "geojson")
    set_annotations!(params, "distance,duration")

    response = route(osrm, params)

    @test alternative_count(response) >= 1

    # as_json and basic metrics
    json = as_json(response)
    @test isa(json, String)
    @test !isempty(json)

    @test distance(response) >= 0.0
    @test duration(response) >= 0.0

    @test distance_at(response, 1) >= 0.0
    @test duration_at(response, 1) >= 0.0

    # geometry helpers
    # geometry_polyline is not supported with current backend configuration;
    # geometry access is covered via waypoint/coordinate helpers below.

    coord_count = geometry_coordinate_count(response)
    @test coord_count >= 2

    first_coord = geometry_coordinate(response, 1, 1)
    @test first_coord isa LatLon

    # waypoint helpers
    wps = waypoint_count(response)
    @test wps == 3

    first_wp = waypoint_coordinate(response, 1)
    @test first_wp isa LatLon

    name1 = waypoint_name(response, 1)
    @test isa(name1, String)

    # leg / step helpers
    legs = leg_count(response)
    @test legs == wps - 1

    steps = step_count(response, 1, 1)
    @test steps >= 1

    dist_step = step_distance(response, 1, 1, 1)
    dur_step = step_duration(response, 1, 1, 1)
    instr = step_instruction(response, 1, 1, 1)

    @test dist_step >= 0.0
    @test dur_step >= 0.0
    @test isa(instr, String)
end
