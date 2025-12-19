# Examples

## Graph building

The Graph module provides the functionality to build OSRM graphs from OpenStreetMap data.
It wraps the OSRM graph CLI commands.

OSRM can handle different OSM data formats, including OSM XML and PBF (Protocol Buffer Format).

OSRM supports two graph types: MLD (Multi-Level Dijkstra) and CH (Contraction Hierarchies).
MLD is the recommended graph type for most use cases.

Each graph is tailored for a specific routing profile that defines how different road types and conditions are weighted.
OSRM provides three built-in profiles: car, bicycle, and foot, which can be specified using the `Profile` enum type.
Custom profiles can be used by providing the path to the profile.lua file(s).

The basic workflow for creating an MLD graph for car is as follows:

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graph

# input data
osm_path = "hamburg-latest.osm.pbf"
# output data
osrm_base_path = "hamburg-latest.osrm"   # base path for all graph files

# Build MLD graph (recommended for most use cases)
extract(osm_path; profile = PROFILE_CAR)
partition(osrm_base_path)
customize(osrm_base_path)
```

The created graph files are automatically read when the OSRM instance is initialized.

## OSRM instance

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
get_default_radius(osrm)
# see the documentation for more parameters
```

This instance can then be used with the service submodules for querying.

## Nearest query

The Nearest module provides the functionality to find the nearest waypoint in a road network for a given position.

The main function is `nearest(osrm, params)`, which takes the OSRM instance and a nearest-specific parameters object as input.

```julia
using OpenSourceRoutingMachine.Nearest

params = NearestParams()
add_coordinate!(params, Position(9.9937, 53.5511))
set_number_of_results!(params, 5)  # Get 5 nearest points
# see the documentation for more parameters

response = nearest(osrm, params; deserialize = true)
```

This results in a `FBResult` object containing the entire response as native Julia objects.

With `deserialize = false`, the response is a `Vector{UInt8}` containing the FlatBuffers binary data.

```julia
response = nearest(osrm, params; deserialize = false)
```

This deserialization option applies to modules that return FlatBuffers: `nearest`, `route`, `match`, `table`, and `trip`.

## Route query

The Route module provides the functionality to calculate the shortest path between two or more waypoints.

The main function is `route(osrm, params)`, which takes the OSRM instance and a route-specific parameters object as input.

For more details on the response options, see the Nearest example above.

```julia
using OpenSourceRoutingMachine.Route

# Create route parameters
params = RouteParams()
set_geometries!(params, GEOMETRIES_GEOJSON) # geometry in uncompressed format
set_overview!(params, OVERVIEW_FULL) # detailed geometry information
set_steps!(params, true) # include steps in the response
set_annotations!(params, ANNOTATIONS_ALL) # include all annotations
add_coordinate!(params, Position(9.9937, 53.5511))  # Start: Hamburg city center
add_coordinate!(params, Position(9.9882, 53.6304))  # End: Hamburg airport
# see the documentation for more parameters

# Calculate route
response = route(osrm, params)
```

## Table query

The Table module provides the functionality to calculate the distance/duration matrices between multiple waypoints.

The main function is `table(osrm, params)`, which takes the OSRM instance and a table-specific parameters object as input.

For more details on the response options, see the Nearest example above.

```julia
using OpenSourceRoutingMachine.Table

params = TableParams()
# Add coordinates first
add_coordinate!(params, Position(9.9937, 53.5511))  # Index 0
add_coordinate!(params, Position(9.9882, 53.6304))  # Index 1
add_coordinate!(params, Position(9.9667, 53.5417))  # Index 2
add_coordinate!(params, Position(9.9352, 53.5528))  # Index 3
# Mark which coordinates are origins and destinations
add_source!(params, 0)
add_source!(params, 1)
add_destination!(params, 2)
add_destination!(params, 3)
# see the documentation for more parameters

response = table(osrm, params)
```

## Match query

The Match module provides the functionality to map noisy GPS traces to a road network.

The main function is `match(osrm, params)`, which takes the OSRM instance and a match-specific parameters object as input.

For more details on the response options, see the Nearest example above.

```julia
using OpenSourceRoutingMachine.Match

params = MatchParams()
set_geometries!(params, GEOMETRIES_GEOJSON) # geometry in uncompressed format
set_overview!(params, OVERVIEW_FULL) # detailed geometry information
set_alternatives!(params, false)  # no alternatives
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# see the documentation for more parameters

response = match(osrm, params)
```

## Trip query

The Trip module provides the functionality to solve the traveling salesman problem, finding the optimal order to visit multiple waypoints.

The main function is `trip(osrm, params)`, which takes the OSRM instance and a trip-specific parameters object as input.

For more details on the response options, see the Nearest example above.

```julia
using OpenSourceRoutingMachine.Trip

params = TripParams()
set_geometries!(params, GEOMETRIES_GEOJSON) # geometry in uncompressed format
set_overview!(params, OVERVIEW_FULL) # detailed geometry information
set_alternatives!(params, false)  # no alternatives
add_coordinate!(params, Position(9.9937, 53.5511))
add_coordinate!(params, Position(9.9940, 53.5512))
add_coordinate!(params, Position(9.9945, 53.5513))
# see the documentation for more parameters

response = trip(osrm, params)
```

## Tile query

The Tile module provides the functionality to retrieve road network geometry as vector tiles in MVT format.

The main function is `tile(osrm, params)`, which takes the OSRM instance and a tile-specific parameters object as input.

```julia
using OpenSourceRoutingMachine.Tile

params = TileParams()
set_x!(params, 4500)  # Tile X coordinate
set_y!(params, 2700)  # Tile Y coordinate
set_z!(params, 13)    # Zoom level
# see the documentation for more parameters

response = tile(osrm, params)
```
