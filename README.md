# OpenSourceRoutingMachine.jl

An thin wrapper around OSRM (Open Source Routing Machine) in Julia.
It provides high-performance routing and matching features in road networks.

## Features

- **Graph module**: Build OSRM graphs (MLD and CH algorithms) from OpenStreetMap data
- **Nearest module**: Find the nearest road segment to a given point in a road network
- **Route module**: Find the route between origin and destination in a road network
- **Match module**: Map noisy GPS traces to a road network
- **Table module**: Compute distance/duration matrices between multiple origin-destination pairs
- **Trip module**: Solve traveling salesman problems
- **Tile module**: Generate road network vector tiles (Mapbox Vector Tiles)

The modules expose the full configuration and parameter handling API of OSRM via setter functions.

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine", url="https://github.com/moviro-hub/OpenSourceRoutingMachine.jl")
```

## Quick Start

###  Graph example
Wrapping the OSRM graph CLI commands.

Before using OSRM services, you need to build a graph from OpenStreetMap data:

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graphs

osm_path = "hamburg-latest.osm.pbf" # or any other OSM file
osrm_base_path = "hamburg-latest.osrm"   # corresponding OSRM base path for all graph files

# Build MLD graph (recommended for most use cases)
extract(osm_path; profile = Profile(0))  # car
partition(osrm_base_path)
customize(osrm_base_path)

# Or build CH graph
extract(osm_path; profile = Profile(0))  # car
contract(osrm_base_path)
```

### Nearest example
Wrapping the OSRM libosrm via libosrmc.

Nearest finds the nearest road segment to a point.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Nearests

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = NearestParams()
set_format!(params, OutputFormat(1))  # flatbuffers
add_coordinate!(params, Position(9.9937, 53.5511))
set_number_of_results!(params, 5)  # Get 5 nearest points
# many more parameters are available, see the documentation

response = nearest(osrm, params)

```

### Route example
Wrapping the OSRM libosrm via libosrmc.

Route calculates the shortest path between two or more waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Routes

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

# Create route parameters
params = RouteParams()
set_format!(params, OutputFormat(1))  # flatbuffers
set_geometries!(params, Geometries(2))  # geojson
set_overview!(params, Overview(2))  # full
set_alternatives!(params, false)  # non
add_coordinate!(params, Position(9.9937, 53.5511))  # Start: Hamburg city center
add_coordinate!(params, Position(9.9882, 53.6304))  # End: Hamburg airport
# many more parameters are available, see the documentation

# Calculate route
response = route(osrm, params; deserialize = true)
```
The response is a julia object of the type `FBResult`.
If the keyword argument `deserialize` is set to `false`, the response is a `Vector{UInt8}` containing the flatbuffers binary data.
If `set_format!(params, OutputFormat(0))` and keyword argument `deserialize` is set to `false` is set, the response is a `String`.
If `set_format!(params, OutputFormat(0))` and keyword argument `deserialize` is set to `true`, the response is a `Dict` containing the JSON data in basic julia types.

This is the same for all modules of this kind, namely `nearest`, `route`, `match`, `table`, `trip`.

###  Table example
Wrapping the OSRM libosrm via libosrmc.

Table computes distance/duration matrices between multiple waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Tables

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = TableParams()
# Add coordinates first
add_coordinate!(params, Position(9.9937, 53.5511))  # Index 0
add_coordinate!(params, Position(9.9882, 53.6304))  # Index 1
add_coordinate!(params, Position(9.9667, 53.5417))  # Index 2
add_coordinate!(params, Position(9.9352, 53.5528))  # Index 3
# Mark which coordinates are origins and destinations
add_source!(params, 1)
add_source!(params, 2)
add_destination!(params, 3)
add_destination!(params, 4)
# many more parameters are available, see the documentation

response = table(osrm, params)
```

### Match example
Wrapping the OSRM libosrm via libosrmc.

Match maps GPS traces to road networks.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Matches

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = MatchParams()
set_format!(params, OutputFormat(1))  # flatbuffers
set_geometries!(params, Geometries(2))  # geojson
set_overview!(params, Overview(2))  # full
set_alternatives!(params, false)  # non
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# many more parameters are available, see the documentation

response = match(osrm, params)
```

### Trip example

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Matches

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = TripParams()
set_format!(params, OutputFormat(1))  # flatbuffers
set_geometries!(params, Geometries(2))  # geojson
set_overview!(params, Overview(2))  # full
set_alternatives!(params, false)  # non
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# many more parameters are available, see the documentation

response = trip(osrm, params)
```

### Tile example

This module generates Mapbox Vector Tiles of the road network.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Tiles

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = TileParams()
add_coordinate!(params, Position(9.9937, 53.5511))
# many more parameters are available, see the documentation

response = tile(osrm, params)
```
