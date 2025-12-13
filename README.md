# OpenSourceRoutingMachine.jl

A thin Julia wrapper for OSRM (Open Source Routing Machine), a high-performance tool for route planning in road networks and related tasks.

## Modules

The structure of the package is as follows.

A core module `OpenSourceRoutingMachine` provides the constructor `OSRM` for creating an OSRM instance and setter functions for basic configuration.

The rest of the functionality is organized in submodules. The submodules have the following scope:

- **Graph module**: Builds OSRM graphs from OpenStreetMap data.
- **Nearest module**: Finds the nearest road segment to a given position.
- **Route module**: Finds the route between waypoints.
- **Match module**: Maps noisy GPS traces to a road network.
- **Table module**: Computes travel matrices between multiple waypoint pairs.
- **Trip module**: Solves traveling salesman problems.
- **Tile module**: Generates road network vector tiles (PBF format).

All modules expose the full configuration and parameter handling API of OSRM through setter functions, providing fine-grained control over query behavior.

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine", url="https://github.com/moviro-hub/OpenSourceRoutingMachine.jl")
```

## Quick Start

###  Graph building

The Graph module provides the functionality to build OSRM graphs from OpenStreetMap data.
It wraps the OSRM graph CLI commands.

OSRM can handle different OSM data formats, including OSM XML and PBF (Protocol Buffer Format).

OSRM has graph types MLD (Multi Level Dijkstra) and CH (Contraction Hierarchies).
MLD is the recommended graph type for most use cases.

Each graph is tailored for a specific routing profile that defines how different road types and conditions are weighted. OSRM provides three built-in profiles: car, bicycle, and foot, which can be specified using the `Profile` enum type. Additionally, custom profiles can be used by providing the path to the profile.lua file(s).

The basic workflow for creating a graph MLD for car is as follows:

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graphs

# input data
osm_path = "hamburg-latest.osm.pbf"
# output data
osrm_base_path = "hamburg-latest.osrm"   # base path for all graph files

# Build MLD graph (recommended for most use cases)
extract(osm_path; profile = profile_car)
partition(osrm_base_path)
customize(osrm_base_path)
```

The created graph files are automatically read when the OSRM instance is initialized.

### OSRM instance

Once the graph is built, you can create an OSRM instance to use the graph.

The OSRM instance is created with the base path of the graph data files.
It also contains configuration settings for the OSRM instance.

```julia
using OpenSourceRoutingMachine
# create the OSRM instance
osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)
# set the default snapping radius to 100 meters
set_default_radius!(osrm, 100.0)
# many more parameters are available, see the documentation
```
This instance can then be used with the following submodules for querying.

Each submodule has its own parameter types and response types, allowing for module-specific configuration.

### Nearest query

The Nearest module provides the functionality to find the nearest road segment to a given position.

The main function is `nearest(osrm, params)`, which takes the OSRM instance and a nearest-specific parameters object as input.

The response format depends on the parameters set. The most common approach is to set the format to `output_format_flatbuffers` and `deserialize` to `true` to obtain a Julia object. See the documentation for more details.

```julia
using OpenSourceRoutingMachine.Nearests

params = NearestParams()
set_format!(params, output_format_flatbuffers)
add_coordinate!(params, Position(9.9937, 53.5511))
set_number_of_results!(params, 5)  # Get 5 nearest points
# many more parameters are available, see the documentation

response = nearest(osrm, params; deserialize = true)
```
This results in a `FBResult` object containing the entire response as native Julia objects.

With `deserialize = false`, the response is a `Vector{UInt8}` containing the flatbuffers binary data.

If JSON output is desired, you can set the format to `output_format_json` and `deserialize` to `false` to obtain a JSON string response.

```julia
set_format!(params, output_format_json)
response = nearest(osrm, params; deserialize = false)
```

This results in a `Dict` containing the JSON data in basic Julia types if `deserialize = true`.

This pattern of format selection and deserialization options applies to all query modules: `nearest`, `route`, `match`, `table`, and `trip`.

### Route example

The Route module provides the functionality to calculate the shortest path between two or more waypoints.

The main function is `route(osrm, params)`, which takes the OSRM instance and a route-specific parameters object as input.

This module structure is similar to the Nearest module.
For more details, of the response options, see the nearest example.

```julia
using OpenSourceRoutingMachine.Routes

# Create route parameters
params = RouteParams()
set_format!(params, output_format_flatbuffers)
set_geometries!(params, geometries_geojson) # geometry in an uncompressed format
set_overview!(params, overview_full) # detail geometry information
set_steps!(params, true) # include steps in the response
set_annotations!(params, annotations_all) # include all annotations
add_coordinate!(params, Position(9.9937, 53.5511))  # Start: Hamburg city center
add_coordinate!(params, Position(9.9882, 53.6304))  # End: Hamburg airport
# many more parameters are available, see the documentation

# Calculate route
response = route(osrm, params)
```


### Table example
The Table module provides the functionality to calculate the distance/duration matrices between multiple waypoints.

The main function is `table(osrm, params)`, which takes the OSRM instance and a table-specific parameters object as input.

This module structure is similar to the Nearest module.
For more details, of the response options, see the nearest example.

```julia
using OpenSourceRoutingMachine.Tables

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
The Match module provides the functionality to map noisy GPS traces to a road network.

The main function is `match(osrm, params)`, which takes the OSRM instance and a match-specific parameters object as input.

This module structure is similar to the Nearest module.
For more details, of the response options, see the nearest example.

```julia
using OpenSourceRoutingMachine.Matches

params = MatchParams()
set_format!(params, output_format_flatbuffers)
set_geometries!(params, geometries_geojson)
set_overview!(params, overview_false)
set_alternatives!(params, false)  # no alternatives
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# many more parameters are available, see the documentation

response = match(osrm, params)
```

### Trip example

The Trip module provides the functionality to solve the traveling salesman problem, finding the optimal order to visit multiple waypoints.

The main function is `trip(osrm, params)`, which takes the OSRM instance and a trip-specific parameters object as input.

This module structure is similar to the Nearest module.
For more details, of the response options, see the nearest example.

```julia
using OpenSourceRoutingMachine.Trips

params = TripParams()
set_format!(params, output_format_flatbuffers)
set_geometries!(params, geometries_geojson)
set_overview!(params, overview_false)
set_alternatives!(params, false)  # no alternatives
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# many more parameters are available, see the documentation

response = trip(osrm, params)
```

### Tile example

The Tile module provides the functionality to generate Mapbox Vector Tiles of the road network.

The main function is `tile(osrm, params)`, which takes the OSRM instance and a tile-specific parameters object as input.

It returns the vector tile data in Mapbox Vector Tile format (PBF), which can be used for rendering road networks in mapping applications.

```julia
using OpenSourceRoutingMachine.Tiles

params = TileParams()
add_coordinate!(params, Position(9.9937, 53.5511))
# many more parameters are available, see the documentation

response = tile(osrm, params)
```


Copyright (c) 2025, Moviro GmbH

Licensed under the MIT License.
