using Test
using OpenSourceRoutingMachine
using Base: C_NULL
using .Fixtures
import OpenSourceRoutingMachine.Trip: TripResponse, waypoint_count, waypoint_latitude,
    waypoint_longitude, as_json

@testset "Trip - Basic" begin
    params = TripParams()
    @test params isa TripParams
    @test params.ptr != C_NULL

    osrm = Fixtures.get_test_osrm()
    coords = Fixtures.hamburg_coordinates()
    for coord in coords
        add_coordinate!(params, coord)
    end

    response = trip(osrm, params)
    @test response isa TripResponse

    dist = try
        distance(response)
    catch e
        @test e isa OSRMError
        nothing
    end
    dur = try
        duration(response)
    catch e
        @test e isa OSRMError
        nothing
    end
    if dist !== nothing
        @test dist >= 0.0f0
    end
    if dur !== nothing
        @test dur >= 0.0f0
    end

    count = waypoint_count(response)
    @test count >= 2

    try
        lat = waypoint_latitude(response, 1)
        lon = waypoint_longitude(response, 1)
        @test -90.0f0 <= lat <= 90.0f0
        @test -180.0f0 <= lon <= 180.0f0
        @test isfinite(lat)
        @test isfinite(lon)
    catch e
        @test e isa OSRMError
    end

    json_str = try
        as_json(response)
    catch e
        @test e isa OSRMError
        ""
    end
    if !isempty(json_str)
        @test isa(json_str, String)
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Trip - Parameters" begin
    params = TripParams()
    add_roundtrip!(params, true)
    add_roundtrip!(params, false)
    add_source!(params, "first")
    add_destination!(params, "last")
    clear_waypoints!(params)
    add_waypoint!(params, 1)
    add_waypoint!(params, 1)

    osrm = Fixtures.get_test_osrm()
    coords = Fixtures.hamburg_coordinates()
    for coord in coords
        add_coordinate!(params, coord)
    end

    response = trip(osrm, params)
    @test waypoint_count(response) >= 2
end

@testset "Trip - Error Handling" begin
    osrm = Fixtures.get_test_osrm()
    params = TripParams()

    add_coordinate!(params, LatLon(0.0f0, 0.0f0))
    add_coordinate!(params, LatLon(1.0f0, 1.0f0))

    maybe_response = try
        trip(osrm, params)
    catch e
        @test e isa OSRMError
        nothing
    end
    if maybe_response !== nothing
        @test maybe_response isa TripResponse
    end
end
