# OpenSourceRoutingMachine.jl

A Julia wrapper for OSRM (Open Source Routing Machine), providing high-performance routing, matching, and geospatial analysis capabilities directly in Julia.

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
Pkg.add("OpenSourceRoutingMachine")
```

Or from the Julia REPL:
```julia
] add OpenSourceRoutingMachine
```

## Quick Start

### Basic Routing

```julia
using OpenSourceRoutingMachine

# Create OSRM instance
config = OSRMConfig("/path/to/your/osrm/data")
osrm = OSRM(config)

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

### Nearest Point

```julia
params = NearestParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
set_number_of_results!(params, 5)  # Get 5 nearest points

response = nearest(osrm, params)
count(response)  # Number of results

# Access first result
lat = latitude(response, 1)
lon = longitude(response, 1)
name_str = name(response, 1)
```

### Map Matching

```julia
params = MatchParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
add_coordinate!(params, LatLon(53.5512, 9.9940))
add_coordinate!(params, LatLon(53.5513, 9.9945))

response = match(osrm, params)
route_cnt = route_count(response)
if route_cnt > 0
    dist = route_distance(response, 1)
    conf = route_confidence(response, 1)
end
```

### Distance Matrix

```julia
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

## Building OSRM Graphs

Before using OSRM services, you need to build a graph from OpenStreetMap data:

> Graph-building helpers (`extract`, `partition`, `customize`, `contract`, and
> `profile_lua_path`) live in the `OpenSourceRoutingMachine.Graphs` module, but
> they remain re-exported at the package root for backwards compatibility.

```julia
using OpenSourceRoutingMachine

osm_path = "hamburg-latest.osm.pbf"

# Output files are created in the same directory as the input with the same base name


# Build MLD graph (recommended for most use cases)
extract(osm_path; profile = Profile.car)
partition(osm_path)
customize(osm_path)

# Or build CH graph
extract(osm_path; profile = Profile.car)
contract(osm_path)

```

## API Overview

### Configuration

- `OSRMConfig(base_path)`: Create configuration for OSRM instance (algorithm auto-detected from data files)
- `OSRM(config)`: Create OSRM instance from configuration
- `set_algorithm!(config, Algorithm.mld)`: Optionally set routing algorithm explicitly (MLD or CH)

### Route Service

Route-specific types and helpers live inside the `OpenSourceRoutingMachine.Routes`
module, but everything below continues to be re-exported from the top-level module
for backwards compatibility.

- `RouteParams()`: Create route parameters
- `add_coordinate!(params, coord::LatLon)`: Add waypoint
- `route(osrm, params)`: Calculate route
- `distance(response)`: Get route distance
- `duration(response)`: Get route duration

### Match Service

Match-specific types and helpers live in the `OpenSourceRoutingMachine.Matches`
module, but they remain re-exported from the root module for backwards
compatibility.

- `MatchParams()`: Create match parameters
- `add_coordinate!(params, coord::LatLon)`: Add GPS trace point
- `add_timestamp!(params, timestamp)`: Add timestamp for trace point
- `match(osrm, params)`: Match trace to road network
- `route_count(response)`: Number of matched routes
- `route_distance(response, index)`: Distance of matched route
- `route_confidence(response, index)`: Confidence score

### Nearest Service

Nearest-specific types and helpers now live in the `OpenSourceRoutingMachine.Nearests`
module, but they remain re-exported for backwards compatibility.

- `NearestParams()`: Create nearest parameters
- `add_coordinate!(params, coord::LatLon)`: Query point
- `set_number_of_results!(params, n)`: Number of results
- `nearest(osrm, params)`: Find nearest points
- `latitude(response, index)`: Latitude of result
- `longitude(response, index)`: Longitude of result
- `name(response, index)`: Street name

### Table Service

Table-specific types and helpers live inside the `OpenSourceRoutingMachine.Tables`
module, but they remain re-exported at the package root for backwards
compatibility.

- `TableParams()`: Create table parameters
- `add_coordinate!(params, coord::LatLon)`: Add coordinate point
- `add_source!(params, index)`: Mark coordinate at index as source
- `add_destination!(params, index)`: Mark coordinate at index as destination
- `table(osrm, params)`: Compute distance/duration matrix

### Trip Service

Trip-specific types and helpers live in the `OpenSourceRoutingMachine.Trips`
module, but they remain re-exported from the root module for backwards
compatibility.

- `TripParams()`: Create trip parameters
- `add_coordinate!(params, coord::LatLon)`: Add waypoint
- `trip(osrm, params)`: Solve TSP

### Tile Service

Tile-specific types and helpers live in the `OpenSourceRoutingMachine.Tiles`
module, but they remain re-exported at the package root for backwards
compatibility.

- `TileParams()`: Create tile parameters
- `set_x!(params, x)`: Set tile X coordinate
- `set_y!(params, y)`: Set tile Y coordinate
- `set_z!(params, z)`: Set tile zoom level
- `tile(osrm, params)`: Get vector tile
- `data(response)`: Get tile data
- `size(response)`: Get tile size

## Error Handling

All OSRM operations may throw `OSRMError` exceptions:

```julia
try
    response = route(osrm, params)
catch e
    if e isa OSRMError
        println("Error: $(e.code) - $(e.message)")
    else
        rethrow(e)
    end
end
```

## Requirements

- Julia 1.10 or later
- OSRM graph data (built from OpenStreetMap)

## License

MIT License - see LICENSE file for details.

## Authors

MOVIRO GmbH
