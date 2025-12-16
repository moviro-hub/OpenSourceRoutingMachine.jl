# OpenSourceRoutingMachine.jl

A thin Julia wrapper for OSRM (Open Source Routing Machine), a high-performance tool for route planning in road networks.

## Modules

The package structure consists of a core module and service submodules.

The core module `OpenSourceRoutingMachine` provides the constructor `OSRM` for creating an OSRM instance and setter and getter functions for basic configuration.

The rest of the functionality is organized in service submodules with the following scope:

- **Graph module**: Builds OSRM graphs from OpenStreetMap data
- **Nearest**: Find the nearest waypoint in a road network for a given position
- **Route**: Find a route between waypoints containing detailed information
- **Table**: Find distance/duration matrices between multiple source and destination waypoints
- **Match**: Find a route by map matching noisy GPS traces to a road network
- **Trip**: Find a route by solving the traveling salesman problem
- **Tile**: Retrieve road network geometry as vector tiles

All modules expose the full configuration and parameter handling API of OSRM through setter and getter functions, providing fine-grained control over query behavior.
The output format is restricted to FlatBuffers for all modules except the Tile module.
The Tile module returns road network geometry in MVT format.

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine", url="https://github.com/moviro-hub/OpenSourceRoutingMachine.jl")
```

See the `Examples` section for end-to-end usage patterns.

## API Reference

```@contents
Pages = [
    "api/core.md",
    "api/graphs.md",
    "api/nearest.md",
    "api/route.md",
    "api/match.md",
    "api/table.md",
    "api/trip.md",
    "api/tile.md",
]
```
