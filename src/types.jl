"""
    LatLon

A named tuple representing a latitude and longitude coordinate.
"""
const LatLon = NamedTuple{(:lat, :lon), Tuple{Float32, Float32}}
LatLon(lat::Real, lon::Real) = (lat = Float32(lat), lon = Float32(lon))
