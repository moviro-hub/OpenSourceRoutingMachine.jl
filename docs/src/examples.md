# Examples

## Graph example

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

## Nearest example

Nearest finds the nearest road segment to a point.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Nearests

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = NearestParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
set_number_of_results!(params, 5)  # Get 5 nearest points

response = nearest(osrm, params)
cnt = get_count(response)  # Number of results

# Access first result
coord = get_coordinate(response, 1)
name = get_name(response, 1)
dist = get_distance(response, 1)
hint = get_hint(response, 1)
```

## Route example

Route calculates the shortest path between two or more waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Routes

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

# Create route parameters
params = RouteParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))  # Start: Hamburg city center
add_coordinate!(params, LatLon(53.6304, 9.9882))  # End: Hamburg airport

# Calculate route
response = route(osrm, params)

# Get results
dist = get_distance(response)      # Distance in meters
dur = get_duration(response)       # Duration in seconds
```

## Match example

Match maps GPS traces to road networks.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Matches

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

params = MatchParams()
add_coordinate!(params, LatLon(53.5511, 9.9937))
add_coordinate!(params, LatLon(53.5512, 9.9940))
add_coordinate!(params, LatLon(53.5513, 9.9945))

response = match(osrm, params)

# Get results
dist = get_distance(response)      # Distance in meters
dur = get_duration(response)       # Duration in seconds
```

## Table example

Table computes distance/duration matrices between multiple waypoints.

```julia
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Tables

osrm_base_path = "hamburg-latest.osrm"
osrm = OSRM(osrm_base_path)

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
durations = get_duration_matrix(response)
distances = get_distance_matrix(response)
```
