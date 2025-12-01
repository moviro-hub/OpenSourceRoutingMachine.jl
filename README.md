# OpenSourceRoutingMachine.jl

This package aims to be a thin wrapper around OSRM.
A Julia wrapper for OSRM (Open Source Routing Machine), providing high-performance routing, matching, and geospatial analysis capabilities directly in Julia.
Being a thin wrapper around OSRM, it might not provide the most ergonomic API, which might be established in a separate package at one point.

## Features

- **Graph Building**: Build and customize OSRM graphs (MLD and CH algorithms)
- **Nearest Service**: Find the nearest road segment to a point
- **Route Service**: Calculate routes between multiple waypoints
- **Match Service**: Map GPS traces to road networks
- **Table Service**: Compute distance/duration matrices
- **Trip Service**: Solve traveling salesman problems
- **Tile Service**: Generate vector tiles for visualization

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine", url="https://github.com/moviro-hub/OpenSourceRoutingMachine.jl")
```

## Quick Start

###  Graph example

Before using OSRM services, you need to build a graph from OpenStreetMap data:

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graphs

osm_path = "hamburg-latest.osm.pbf" # or any other OSM file
osrm_base_path = "hamburg-latest.osrm"   # corresponding OSRM base path for all graph files

# Build MLD graph (recommended for most use cases)
extract(osm_path; profile = Profile.car)
partition(osrm_base_path)
customize(osrm_base_path)

# Or build CH graph
extract(osm_path; profile = Profile.car)
contract(osrm_base_path)
```

### Nearest example

Nearest finds the nearest road segment to a point.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Nearests

osrm = OSRM("hamburg-latest")

params = NearestParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
set_number_of_results!(params, 5)  # Get 5 nearest points

response = nearest(osrm, params)
count(response)  # Number of results

# Access first result
lat = latitude(response, 1)
lon = longitude(response, 1)
name_str = get_name(response, 1)
```

### Route example

Route calculates the shortest path between two or more waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Routes

# Create OSRM instance
osrm = OSRM("hamburg-latest")

# Create route parameters
params = RouteParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))  # Start: Hamburg city center
add_coordinate!(params, LatLon(53.6304, 9.9882))  # End: Hamburg airport

# Calculate route
response = route(osrm, params)

# Get results
dist = distance(response)      # Distance in meters
dur = duration(response)       # Duration in seconds
```

``

### Match example

Match maps GPS traces to road networks.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Matches

osrm = OSRM("hamburg-latest")

params = MatchParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
add_coordinate!(params, LatLon(53.5512, 9.9940))
add_coordinate!(params, LatLon(53.5513, 9.9945))

response = match(osrm, params)
route_cnt = get_route_count(response)
if route_cnt > 0
    dist = route_distance(response, 1)
    conf = route_confidence(response, 1)
end
```

###  Table example

Table computes distance/duration matrices between multiple waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Tables

osrm = OSRM("hamburg-latest")

params = TableParams()
# Add coordinates first
add_coordinate!(params, LatLon(53.5511, 9.9937))  # Index 0
add_coordinate!(params, LatLon(53.6304, 9.9882))  # Index 1
add_coordinate!(params, LatLon(53.5417, 9.9667))  # Index 2
add_coordinate!(params, LatLon(53.5528, 9.9352))  # Index 3

# Mark which coordinates are sources and destinations
add_source!(params, 1)
add_source!(params, 2)
add_destination!(params, 3)
add_destination!(params, 4)

response = table(osrm, params)
# Access distance/duration between sources and destinations
```
