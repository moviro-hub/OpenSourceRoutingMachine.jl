"""
    LatLon

A named tuple representing a latitude and longitude coordinate using `Float64`
precision so we do not lose detail before handing values to libosrmc.
"""
const LatLon = NamedTuple{(:lat, :lon), Tuple{Float64, Float64}}
LatLon(lat::Real, lon::Real) = (lat = Float64(lat), lon = Float64(lon))
