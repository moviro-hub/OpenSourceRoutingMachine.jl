#!/usr/bin/env julia
# Generate test data for match tests by computing routes and adding noise.
# Run this script to regenerate the test coordinates stored in fixtures.jl.

include("test_data.jl")
include("fixtures.jl")
using OpenSourceRoutingMachine
using Random

"""
    generate_noisy_route_coordinates(osrm, start_lon, start_lat, end_lon, end_lat; noise_meters=10.0, max_points=50)

Compute a route between two points, extract the path coordinates, and add random noise.
Returns a vector of (latitude, longitude) tuples suitable for match testing.
If routing fails, falls back to interpolating along a straight line with noise.
"""
function generate_noisy_route_coordinates(osrm, start_lon, start_lat, end_lon, end_lat; noise_meters=10.0, max_points=50)
    # First, try to snap points using nearest service
    start_snapped = try
        np = NearestParams()
        add_coordinate!(np, LatLon(start_lat, start_lon))
        nearest_resp = nearest(osrm, np)
        if count(nearest_resp) > 0
            LatLon(latitude(nearest_resp, 0), longitude(nearest_resp, 0))
        else
            LatLon(start_lat, start_lon)
        end
    catch
        LatLon(start_lat, start_lon)
    end

    end_snapped = try
        np = NearestParams()
        add_coordinate!(np, LatLon(end_lat, end_lon))
        nearest_resp = nearest(osrm, np)
        if count(nearest_resp) > 0
            LatLon(latitude(nearest_resp, 0), longitude(nearest_resp, 0))
        else
            LatLon(end_lat, end_lon)
        end
    catch
        LatLon(end_lat, end_lon)
    end

    # Try to compute route between snapped points
    route_coords = try
        route_params = RouteParams()
        add_coordinate!(route_params, start_snapped)
        add_coordinate!(route_params, end_snapped)

        route_response = route(osrm, route_params)

        # Extract geometry coordinates
        coord_count = geometry_coordinate_count(route_response, 0)
        if coord_count > 0
            # Sample coordinates (take every Nth coordinate if too many)
            step = max(1, coord_count ÷ max_points)
            sampled_indices = 1:step:coord_count

            coords = Vector{LatLon}()
            for i in sampled_indices
                lat = geometry_coordinate_latitude(route_response, 0, i - 1)  # 0-indexed
                lon = geometry_coordinate_longitude(route_response, 0, i - 1)
                push!(coords, LatLon(lat, lon))
            end
            coords
        else
            nothing
        end
    catch
        nothing
    end

    # If routing failed, interpolate along a straight line
    if route_coords === nothing
        num_points = max_points
        coords = Vector{LatLon}()
        for i in 0:(num_points-1)
            t = i / (num_points - 1)
            lat = start_snapped.lat + t * (end_snapped.lat - start_snapped.lat)
            lon = start_snapped.lon + t * (end_snapped.lon - start_snapped.lon)
            push!(coords, LatLon(lat, lon))
        end
        route_coords = coords
    end

    # Add random noise to all coordinates
    noisy_coords = Vector{LatLon}()
    for coord in route_coords
        # Add random noise (convert meters to approximate degrees)
        # Rough approximation: 1 degree latitude ≈ 111km, 1 degree longitude ≈ 111km * cos(latitude)
        lat_noise = noise_meters / 111000.0 * (2 * rand() - 1)  # ±noise_meters in degrees
        lon_noise = noise_meters / (111000.0 * cos(deg2rad(coord.lat))) * (2 * rand() - 1)

        push!(noisy_coords, LatLon(Float32(coord.lat + lat_noise), Float32(coord.lon + lon_noise)))
    end

    return noisy_coords
end

# Set random seed for reproducibility
Random.seed!(42)

# Generate test coordinates
osrm = Fixtures.get_test_osrm()

println("Generating match test coordinates...")

# Helper to get coordinates from a route (without noise)
function get_route_coordinates(osrm, start_lon, start_lat, end_lon, end_lat, max_points=20)
    # Snap points using nearest
    start_snapped = try
        np = NearestParams()
        add_coordinate!(np, LatLon(start_lat, start_lon))
        nearest_resp = nearest(osrm, np)
        if count(nearest_resp) > 0
            LatLon(latitude(nearest_resp, 0), longitude(nearest_resp, 0))
        else
            LatLon(start_lat, start_lon)
        end
    catch
        LatLon(start_lat, start_lon)
    end

    end_snapped = try
        np = NearestParams()
        add_coordinate!(np, LatLon(end_lat, end_lon))
        nearest_resp = nearest(osrm, np)
        if count(nearest_resp) > 0
            LatLon(latitude(nearest_resp, 0), longitude(nearest_resp, 0))
        else
            LatLon(end_lat, end_lon)
        end
    catch
        LatLon(end_lat, end_lon)
    end

    # Try to compute route
    try
        route_params = RouteParams()
        add_coordinate!(route_params, start_snapped)
        add_coordinate!(route_params, end_snapped)

        route_response = route(osrm, route_params)

        coord_count = geometry_coordinate_count(route_response, 0)
        if coord_count > 0
            step = max(1, coord_count ÷ max_points)
            sampled_indices = 1:step:coord_count

            coords = Vector{LatLon}()
            for i in sampled_indices
                lat = geometry_coordinate_latitude(route_response, 0, i - 1)
                lon = geometry_coordinate_longitude(route_response, 0, i - 1)
                push!(coords, LatLon(lat, lon))
            end
            return coords
        end
    catch
    end

    # Fallback: interpolate between snapped points
    num_points = max_points
    coords = Vector{LatLon}()
    for i in 0:(num_points-1)
        t = i / (num_points - 1)
        lat = start_snapped.lat + t * (end_snapped.lat - start_snapped.lat)
        lon = start_snapped.lon + t * (end_snapped.lon - start_snapped.lon)
        push!(coords, LatLon(lat, lon))
    end
    return coords
end

# Helper to validate coordinates produce a valid match
function validate_match_coordinates(osrm, coords)
    params = MatchParams()
    for coord in coords
        add_coordinate!(params, coord)
    end
    try
        response = match(osrm, params)
        route_cnt = route_count(response)
        return route_cnt > 0
    catch
        return false
    end
end

# Helper to find working coordinates by trying nearby points
function find_working_match_coordinates(osrm, center_lon, center_lat, max_distance_km=5.0)
    # Start from center and try to find a route to nearby points
    np = NearestParams()
    add_coordinate!(np, LatLon(center_lat, center_lon))
    nearest_resp = nearest(osrm, np)
    if count(nearest_resp) == 0
        return nothing
    end

    center_snapped = LatLon(latitude(nearest_resp, 0), longitude(nearest_resp, 0))

    # Try points in different directions
    for angle_deg in [0, 45, 90, 135, 180, 225, 270, 315]
        angle_rad = deg2rad(angle_deg)
        # Try different distances
        for dist_km in [1.0, 2.0, 3.0, 5.0]
            # Calculate destination point
            lat_offset = dist_km / 111.0  # rough km to degrees
            lon_offset = dist_km / (111.0 * cos(deg2rad(center_snapped.lat)))

            dest_lat = center_snapped.lat + lat_offset * sin(angle_rad)
            dest_lon = center_snapped.lon + lon_offset * cos(angle_rad)

            # Try to get route coordinates
            coords = get_route_coordinates(osrm, center_snapped.lon, center_snapped.lat, dest_lon, dest_lat, 15)

            # Validate match
            if validate_match_coordinates(osrm, coords)
                return coords
            end
        end
    end
    return nothing
end

# Generate coordinates by finding working routes from city center
println("Generating CITY_CENTER_TO_AIRPORT...")
global MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT = find_working_match_coordinates(
    osrm, Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat, 5.0
)
if MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT === nothing
    # Fallback: use route coordinates without noise
    coords = get_route_coordinates(
        osrm,
        Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat,  # (lon, lat) for function params
        Fixtures.HAMBURG_AIRPORT.lon, Fixtures.HAMBURG_AIRPORT.lat,  # (lon, lat) for function params
        15
    )
    # Add minimal noise
    coords = [LatLon(coord.lat + 0.0001f0 * (2 * rand() - 1), coord.lon + 0.0001f0 * (2 * rand() - 1)) for coord in coords]
    if validate_match_coordinates(osrm, coords)
        global MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT = coords
    else
        error("Failed to generate valid match coordinates for CITY_CENTER_TO_AIRPORT")
    end
else
    println("  ✓ Found working coordinates")
end

println("Generating CITY_CENTER_TO_PORT...")
global MATCH_TEST_COORDS_CITY_CENTER_TO_PORT = find_working_match_coordinates(
    osrm, Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat, 5.0  # (lon, lat) for function params
)
if MATCH_TEST_COORDS_CITY_CENTER_TO_PORT === nothing
    coords = get_route_coordinates(
        osrm,
        Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat,  # (lon, lat) for function params
        Fixtures.HAMBURG_PORT.lon, Fixtures.HAMBURG_PORT.lat,  # (lon, lat) for function params
        15
    )
    coords = [LatLon(coord.lat + 0.0001f0 * (2 * rand() - 1), coord.lon + 0.0001f0 * (2 * rand() - 1)) for coord in coords]
    if validate_match_coordinates(osrm, coords)
        global MATCH_TEST_COORDS_CITY_CENTER_TO_PORT = coords
    else
        error("Failed to generate valid match coordinates for CITY_CENTER_TO_PORT")
    end
else
    println("  ✓ Found working coordinates")
end

println("Generating CITY_CENTER_TO_ALTONA...")
global MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA = find_working_match_coordinates(
    osrm, Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat, 5.0  # (lon, lat) for function params
)
if MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA === nothing
    coords = get_route_coordinates(
        osrm,
        Fixtures.HAMBURG_CITY_CENTER.lon, Fixtures.HAMBURG_CITY_CENTER.lat,  # (lon, lat) for function params
        Fixtures.HAMBURG_ALTONA.lon, Fixtures.HAMBURG_ALTONA.lat,  # (lon, lat) for function params
        15
    )
    coords = [LatLon(coord.lat + 0.0001f0 * (2 * rand() - 1), coord.lon + 0.0001f0 * (2 * rand() - 1)) for coord in coords]
    if validate_match_coordinates(osrm, coords)
        global MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA = coords
    else
        error("Failed to generate valid match coordinates for CITY_CENTER_TO_ALTONA")
    end
else
    println("  ✓ Found working coordinates")
end

# Generate multi-segment from working coordinates
println("Generating MULTI_SEGMENT...")
if MATCH_TEST_COORDS_CITY_CENTER_TO_PORT !== nothing && MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA !== nothing
    # Use first half of PORT route and second half of ALTONA route
    mid = length(MATCH_TEST_COORDS_CITY_CENTER_TO_PORT) ÷ 2
    global MATCH_TEST_COORDS_MULTI_SEGMENT = vcat(
        MATCH_TEST_COORDS_CITY_CENTER_TO_PORT[1:mid],
        MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA[(mid+1):end]
    )
    if !validate_match_coordinates(osrm, MATCH_TEST_COORDS_MULTI_SEGMENT)
        # Try simpler approach
        global MATCH_TEST_COORDS_MULTI_SEGMENT = vcat(
            MATCH_TEST_COORDS_CITY_CENTER_TO_PORT,
            MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA[2:end]
        )
    end
    println("  ✓ Created multi-segment route")
else
    error("Failed to generate valid match coordinates for MULTI_SEGMENT")
end

println("Generated test coordinates:")
println("  CITY_CENTER_TO_AIRPORT: $(length(MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT)) points")
println("  CITY_CENTER_TO_PORT: $(length(MATCH_TEST_COORDS_CITY_CENTER_TO_PORT)) points")
println("  CITY_CENTER_TO_ALTONA: $(length(MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA)) points")
println("  MULTI_SEGMENT: $(length(MATCH_TEST_COORDS_MULTI_SEGMENT)) points")

# Output as Julia code that can be pasted into fixtures.jl
println("\n=== Copy the following into fixtures.jl ===")
println()
println("# Match test coordinates (generated by generate_match_test_data.jl)")
println("const MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT = [")
for coord in MATCH_TEST_COORDS_CITY_CENTER_TO_AIRPORT
    println("    LatLon($(coord.lat), $(coord.lon)),")
end
println("]")
println()
println("const MATCH_TEST_COORDS_CITY_CENTER_TO_PORT = [")
for coord in MATCH_TEST_COORDS_CITY_CENTER_TO_PORT
    println("    LatLon($(coord.lat), $(coord.lon)),")
end
println("]")
println()
println("const MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA = [")
for coord in MATCH_TEST_COORDS_CITY_CENTER_TO_ALTONA
    println("    LatLon($(coord.lat), $(coord.lon)),")
end
println("]")
println()
println("const MATCH_TEST_COORDS_MULTI_SEGMENT = [")
for coord in MATCH_TEST_COORDS_MULTI_SEGMENT
    println("    LatLon($(coord.lat), $(coord.lon)),")
end
println("]")
