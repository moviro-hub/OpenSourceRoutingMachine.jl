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
