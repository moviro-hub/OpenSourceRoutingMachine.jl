"""
    LatLon

A named tuple representing a latitude and longitude coordinate pair.
"""
const LatLon = NamedTuple{(:lat, :lon), Tuple{Float64, Float64}}
LatLon(lat::Real, lon::Real) = (lat = Float64(lat), lon = Float64(lon))

"""
    Snapping

Selects the snapping behavior OSRM should use for a given dataset (`default`, `any`).
"""
@enumx Snapping::Int begin
    default = 0
    any = 1
end

"""
    Approach

Selects the approach behavior OSRM should use for a given dataset (`curb`, `unrestricted`, `opposite`).
"""
@enumx Approach::Int begin
    curb = 0
    unrestricted = 1
    opposite = 2
end


"""
    Algorithm

Selects the routing algorithm OSRM should use for a given dataset (`ch`, `mld`).
"""
@enumx Algorithm::Int begin
    ch = 0
    mld = 1
end
