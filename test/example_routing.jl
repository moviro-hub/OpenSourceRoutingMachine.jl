#!/usr/bin/env julia
# Minimal example: Set up Hamburg graph and perform routing

using Pkg
Pkg.activate(@__DIR__)
try
    using CairoMakie
    using Tyler
catch
    @info "Installing CairoMakie and Tyler..."
    Pkg.add(["CairoMakie", "Tyler"])
    using CairoMakie
    using Tyler
end
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine: RouteParams, RouteResponse, route, distance, duration,
    geometry_coordinate_count, geometry_coordinate_longitude, geometry_coordinate_latitude,
    waypoint_count, waypoint_longitude, waypoint_latitude, add_coordinate!

include("test_data.jl")
include("fixtures.jl")

# Helper function to extract route geometry
function get_route_coordinates(response::RouteResponse, route_index=1)
    n = geometry_coordinate_count(response, route_index)
    lons = [geometry_coordinate_longitude(response, route_index, i) for i in 1:n]
    lats = [geometry_coordinate_latitude(response, route_index, i) for i in 1:n]
    return lons, lats
end

# Helper function to plot a route with Makie and Tyler
function plot_route(response::RouteResponse, title::String, route_index=1)
    lons, lats = get_route_coordinates(response, route_index)

    # Get waypoints
    n_waypoints = waypoint_count(response)
    waypoint_lons = [waypoint_longitude(response, i) for i in 1:n_waypoints]
    waypoint_lats = [waypoint_latitude(response, i) for i in 1:n_waypoints]

    # Calculate bounds with padding
    lon_min, lon_max = extrema(lons)
    lat_min, lat_max = extrema(lats)
    lon_pad = (lon_max - lon_min) * 0.1
    lat_pad = (lat_max - lat_min) * 0.1

    # Create figure and axis with Makie
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], title=title,
              xlabel="Longitude", ylabel="Latitude",
              limits=(lon_min - lon_pad, lon_max + lon_pad,
                      lat_min - lat_pad, lat_max + lat_pad),
              aspect=AxisAspect(1))

    # Add map tiles using Tyler (optional - comment out if Tyler API issues)
    try
        m = Tyler.Map(; figure=fig, axis=ax, max_parallel_downloads=8)
        Tyler.plot!(ax, m)
        # Wait for Tyler tiles to load
        if isdefined(Tyler, :wait_for_tiles)
            Tyler.wait_for_tiles(m)
        else
            sleep(2)  # Fallback: wait 2 seconds for tiles to download
        end
    catch
        # If Tyler fails, just plot without map tiles
        @warn "Could not load map tiles, plotting route only"
    end

    # Plot route line
    lines!(ax, lons, lats, color=:blue, linewidth=3)

    # Plot waypoints
    scatter!(ax, waypoint_lons, waypoint_lats,
             color=:red, markersize=15,
             strokewidth=2, strokecolor=:white)

    return fig
end

# Set up OSRM instance with Hamburg graph
osrm = Fixtures.get_test_osrm()
println("✓ OSRM instance ready")

# Example 1: Route from City Center to Airport
println("\n📍 Route: City Center → Airport")
params = RouteParams()
add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
response1 = route(osrm, params)
println("  Distance: $(round(distance(response1); digits=2)) m")
println("  Duration: $(round(duration(response1); digits=2)) s")

# Example 2: Route with multiple waypoints
println("\n📍 Route: City Center → Port → Altona")
params = RouteParams()
add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
add_coordinate!(params, Fixtures.HAMBURG_PORT)
add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
response2 = route(osrm, params)
println("  Distance: $(round(distance(response2); digits=2)) m")
println("  Duration: $(round(duration(response2); digits=2)) s")

# Plot routes
println("\n📊 Generating plots...")
fig1 = plot_route(response1, "Route: City Center → Airport")
fig2 = plot_route(response2, "Route: City Center → Port → Altona")

# Save plots
save("route_plot_1.png", fig1)
save("route_plot_2.png", fig2)
println("  Saved to route_plot_1.png and route_plot_2.png")

println("\n✓ Routing examples completed")
