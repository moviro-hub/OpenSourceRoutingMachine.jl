"""
Parameter types for all OSRM services so higher-level wrappers share consistent
lifetime management and string/enum conversions.
"""
module Params

using ..CWrapper: CWrapper
using ..Error: Error
using ..Enums: Enums
using ..OpenSourceRoutingMachine: LatLon

@inline _error_ptr(ref::Ref{Ptr{Cvoid}}) = Base.unsafe_convert(Ptr{Ptr{Cvoid}}, ref)

@inline function _call_with_error(f::Function)
    error_ref = Ref{Ptr{Cvoid}}(C_NULL)
    result = f(error_ref)
    Error.check_error(error_ref)
    return result
end

@inline function _cstring(str::AbstractString)
    cstr = Base.cconvert(Cstring, str)
    return Base.unsafe_convert(Cstring, cstr)
end

@inline function _cstring_or_null(str::Union{AbstractString, Nothing})
    return str === nothing ? C_NULL : _cstring(str)
end

@inline _bool_to_cint(flag::Bool) = flag ? Cint(1) : Cint(0)

abstract type OSRMParams end

function _finalize_param!(params, destructor)
    return finalizer(params) do p
        if p.ptr != C_NULL
            destructor(p.ptr)
            p.ptr = C_NULL
        end
    end
end

"""
    RouteParams()

Owns the native route parameter handle so callers can build requests without
allocating temporary structs for every query.
"""
mutable struct RouteParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function RouteParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_route_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_route_params_destruct)
        return params
    end
end

"""
    TableParams()

Wraps libosrmc's table parameter object, keeping the GC responsible for cleanup
while you build many-to-many queries in Julia.
"""
mutable struct TableParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function TableParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_table_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_table_params_destruct)
        return params
    end
end

"""
    NearestParams()

Provides a reusable parameter block for Nearest requests so iterative proximity
searches do not constantly rebuild C structs.
"""
mutable struct NearestParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function NearestParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_nearest_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_nearest_params_destruct)
        return params
    end
end

"""
    MatchParams()

Holds the map-matching options (timestamps, gap handling, etc.) so GPS trace
processing can mutate a single object across requests.
"""
mutable struct MatchParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function MatchParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_match_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_match_params_destruct)
        return params
    end
end

"""
    TripParams()

Encapsulates trip-specific toggles like roundtrips and fixed endpoints, letting
you experiment with tour planning without reinitializing libosrm state.
"""
mutable struct TripParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function TripParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_trip_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_trip_params_destruct)
        return params
    end
end

"""
    TileParams()

Keeps an OSRM tile request mutable so map viewers can update XYZ coordinates in
place when users pan the map.
"""
mutable struct TileParams <: OSRMParams
    ptr::Ptr{Cvoid}

    function TileParams()
        ptr = _call_with_error() do error_ptr
            CWrapper.osrmc_tile_params_construct(_error_ptr(error_ptr))
        end
        params = new(ptr)
        _finalize_param!(params, CWrapper.osrmc_tile_params_destruct)
        return params
    end
end

"""
    add_coordinate!(params::OSRMParams, coord::LatLon)

Central entry point for feeding coordinates into any service, avoiding
service-specific copies of the same ccall.
"""
function add_coordinate!(params::OSRMParams, coord::LatLon)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_add_coordinate(params.ptr, Cfloat(coord.lon), Cfloat(coord.lat), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_coordinate_with!(params, coord::LatLon, radius, bearing, range)

Extends `add_coordinate!` with snapping hints so callers don't have to juggle
separate APIs for metadata-rich requests.
"""
function add_coordinate_with!(params::OSRMParams, coord::LatLon, radius::Real, bearing::Integer, range::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_add_coordinate_with(
            params.ptr,
            Cfloat(coord.lon),
            Cfloat(coord.lat),
            Cfloat(radius),
            Cint(bearing),
            Cint(range),
            _error_ptr(error_ptr),
        )
        nothing
    end
    return params
end

function set_hint!(params::OSRMParams, coordinate_index::Integer, hint::AbstractString)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_hint(params.ptr, Csize_t(coordinate_index - 1), _cstring(hint), _error_ptr(error_ptr))
        nothing
    end
    return params
end

function set_radius!(params::OSRMParams, coordinate_index::Integer, radius::Real)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_radius(params.ptr, Csize_t(coordinate_index - 1), Cdouble(radius), _error_ptr(error_ptr))
        nothing
    end
    return params
end

function set_bearing!(params::OSRMParams, coordinate_index::Integer, value::Integer, range::Integer)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_bearing(params.ptr, Csize_t(coordinate_index - 1), Cint(value), Cint(range), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_approach!(params::OSRMParams, coordinate_index, approach)

Hints OSRM about which side of the road is acceptable, reducing snapped routes
that require U-turns when curb constraints matter.
"""
function set_approach!(params::OSRMParams, coordinate_index::Integer, approach)
    @assert coordinate_index >= 1 "Julia uses 1-based indexing"
    code = Enums.to_cint(approach, Enums.Approach)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_approach(params.ptr, Csize_t(coordinate_index - 1), code, _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_exclude!(params::OSRMParams, profile)

Lets you reuse the same request while filtering lane subsets (e.g. tolls) so
experiments with different restrictions stay cheap.
"""
function add_exclude!(params::OSRMParams, profile::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_add_exclude(params.ptr, _cstring(profile), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_generate_hints!(params::OSRMParams, on)

Enable OSRM's hint caching so repeated queries skip expensive coordinate
lookups when the same waypoints are requested.
"""
function set_generate_hints!(params::OSRMParams, on::Bool)
    CWrapper.osrmc_params_set_generate_hints(params.ptr, _bool_to_cint(on))
    return params
end

"""
    set_skip_waypoints!(params::OSRMParams, on)

Asks OSRM to omit waypoint data when you only care about summaries, reducing
response size for high-volume routing.
"""
function set_skip_waypoints!(params::OSRMParams, on::Bool)
    CWrapper.osrmc_params_set_skip_waypoints(params.ptr, _bool_to_cint(on))
    return params
end

"""
    set_snapping!(params::OSRMParams, snapping)

Controls whether coordinates may snap to any edge or remain strict, which helps
stabilize results for noisy GPS traces.
"""
function set_snapping!(params::OSRMParams, snapping)
    code = Enums.to_cint(snapping, Enums.Snapping)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_snapping(params.ptr, code, _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_format!(params::OSRMParams, format)

Switch between JSON and Flatbuffers so you can trade readability for transfer
size without reconstructing params.
"""
function set_format!(params::OSRMParams, format)
    code = Enums.to_cint(format, Enums.OutputFormat)
    _call_with_error() do error_ptr
        CWrapper.osrmc_params_set_format(params.ptr, code, _error_ptr(error_ptr))
        nothing
    end
    return params
end

# Route-specific options stay grouped together so this file mirrors the OSRM
# HTTP documentation structure.

"""
    add_steps!(params::RouteParams, on)

Requests OSRM to emit per-step instructions, which is necessary when building
turn-by-turn guidance layers.
"""
function add_steps!(params::RouteParams, on::Bool)
    CWrapper.osrmc_route_params_add_steps(params.ptr, _bool_to_cint(on))
    return params
end

"""
    add_alternatives!(params::RouteParams, on)

Signals that clients plan to evaluate multiple candidate routes, so OSRM keeps
producing alternates instead of pruning early.
"""
function add_alternatives!(params::RouteParams, on::Bool)
    CWrapper.osrmc_route_params_add_alternatives(params.ptr, _bool_to_cint(on))
    return params
end

"""
    set_geometries!(params::RouteParams, geometries)

Choose between polyline encodings to match downstream consumers (e.g. GeoJSON
vs. polyline6) without rebuilding the request object.
"""
function set_geometries!(params::RouteParams, geometries::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_set_geometries(params.ptr, _cstring(geometries), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_overview!(params::RouteParams, overview)

Controls how much geometry OSRM should include (full, simplified, or none),
which directly impacts payload size.
"""
function set_overview!(params::RouteParams, overview::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_set_overview(params.ptr, _cstring(overview), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_continue_straight!(params::RouteParams, on)

Prevents OSRM from suggesting hairpins at roundabouts when the application
requires staying aligned with the current heading.
"""
function set_continue_straight!(params::RouteParams, on::Bool)
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_set_continue_straight(params.ptr, _bool_to_cint(on), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_number_of_alternatives!(params::RouteParams, count)

Caps how many alternates OSRM should compute so you can bound latency for
interactive use cases.
"""
function set_number_of_alternatives!(params::RouteParams, count::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_set_number_of_alternatives(params.ptr, Cuint(count), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_annotations!(params::RouteParams, annotations)

Asks OSRM to emit per-edge metadata (speed, duration, etc.) so analytics jobs
can inspect costs at a finer granularity.
"""
function set_annotations!(params::RouteParams, annotations::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_set_annotations(params.ptr, _cstring(annotations), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_waypoint!(params::RouteParams, index)

Marks the current coordinate as a waypoint so OSRM reports where routes diverge
or visit intermediate stops.
"""
function add_waypoint!(params::RouteParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_route_params_add_waypoint(params.ptr, Csize_t(index - 1), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    clear_waypoints!(params::RouteParams)

Resets waypoint selections in-place, letting you reuse the same parameter block
for multiple experiments without reconstructing coordinates.
"""
function clear_waypoints!(params::RouteParams)
    CWrapper.osrmc_route_params_clear_waypoints(params.ptr)
    return params
end

# Table service helpers get their own section to match the libosrm
# documentation and make discovery easier.

"""
    add_source!(params::TableParams, index)

Selects which coordinate acts as a source so you can build sparse matrices
without reallocating params for each subset.
"""
function add_source!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_add_source(params.ptr, Csize_t(index - 1), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_destination!(params::TableParams, index)

Same as `add_source!` but for destinations, enabling asymmetric matrices when
needed.
"""
function add_destination!(params::TableParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_add_destination(params.ptr, Csize_t(index - 1), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_annotations_mask!(params::TableParams, mask)

Restricts OSRM's matrix annotations (duration, distance, etc.) so data exports
only include the metrics you plan to consume.
"""
function set_annotations_mask!(params::TableParams, mask::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_set_annotations_mask(params.ptr, _cstring(mask), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_fallback_speed!(params::TableParams, speed)

Defines the heuristic speed OSRM should use when a cell is unreachable, letting
you distinguish true disconnections from missing data.
"""
function set_fallback_speed!(params::TableParams, speed::Real)
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_set_fallback_speed(params.ptr, Cdouble(speed), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_fallback_coordinate_type!(params::TableParams, coord_type)

Controls whether fallback results snap to input coordinates or to network
snaps, ensuring downstream code interprets placeholders correctly.
"""
function set_fallback_coordinate_type!(params::TableParams, coord_type::Union{AbstractString, Nothing})
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_set_fallback_coordinate_type(params.ptr, _cstring_or_null(coord_type), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_scale_factor!(params::TableParams, factor)

Scales unreachable entries so visualization layers can downplay them rather
than treating them as raw infinity.
"""
function set_scale_factor!(params::TableParams, factor::Real)
    _call_with_error() do error_ptr
        CWrapper.osrmc_table_params_set_scale_factor(params.ptr, Cdouble(factor), _error_ptr(error_ptr))
        nothing
    end
    return params
end

# Nearest service exposes only a single extra knob, but we still dedicate a
# section to keep parity with OSRM's HTTP API layout.

"""
    set_number_of_results!(params::NearestParams, n)

Caps how many candidates OSRM should return, keeping proximity lookups bounded
for UIs that only display the top-k matches.
"""
function set_number_of_results!(params::NearestParams, n::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_nearest_set_number_of_results(params.ptr, Cuint(n), _error_ptr(error_ptr))
        nothing
    end
    return params
end

# Match service options include extra metadata (timestamps, tidy), so we group
# them for quick scanning when responding to GPS-related issues.

"""
    add_timestamp!(params::MatchParams, timestamp)

Feeds per-point timestamps so OSRM can respect vehicle speed between samples,
which improves matching on sparse GPS data.
"""
function add_timestamp!(params::MatchParams, timestamp::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_match_params_add_timestamp(params.ptr, Cuint(timestamp), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_gaps!(params::MatchParams, gaps)

Tells OSRM how to treat missing samples (split vs. ignore), letting analytics
pipelines encode their tolerance for GPS outages.
"""
function set_gaps!(params::MatchParams, gaps::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_match_params_set_gaps(params.ptr, _cstring(gaps), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_tidy!(params::MatchParams, on)

Requests OSRM to drop redundant tracepoints, which reduces downstream storage
when high-frequency logs are matched.
"""
function set_tidy!(params::MatchParams, on::Bool)
    _call_with_error() do error_ptr
        CWrapper.osrmc_match_params_set_tidy(params.ptr, _bool_to_cint(on), _error_ptr(error_ptr))
        nothing
    end
    return params
end

# Trip service controls (roundtrips, waypoint overrides) are kept together to
# highlight how they differ from plain routing.

"""
    add_roundtrip!(params::TripParams, on)

Controls whether OSRM should force start and end to coincide, critical when
optimizing delivery tours vs. point-to-point trips.
"""
function add_roundtrip!(params::TripParams, on::Bool)
    _call_with_error() do error_ptr
        CWrapper.osrmc_trip_params_add_roundtrip(params.ptr, _bool_to_cint(on), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_source!(params::TripParams, source)

Fixes the trip's start behavior (first/last/any), ensuring OSRM respects
business constraints like fixed depots.
"""
function add_source!(params::TripParams, source::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_trip_params_add_source(params.ptr, _cstring(source), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    add_destination!(params::TripParams, destination)

Same as `add_source!` but for the tour endpoint so depot returns and open tours
can be modeled explicitly.
"""
function add_destination!(params::TripParams, destination::AbstractString)
    _call_with_error() do error_ptr
        CWrapper.osrmc_trip_params_add_destination(params.ptr, _cstring(destination), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    clear_waypoints!(params::TripParams)

Removes any previously selected fixed stops so you can iterate on waypoint
ordering without reallocating params.
"""
function clear_waypoints!(params::TripParams)
    CWrapper.osrmc_trip_params_clear_waypoints(params.ptr)
    return params
end

"""
    add_waypoint!(params::TripParams, index)

Locks a coordinate index as a fixed visit, which is necessary when mixing
mandatory stops with OSRM's optimized order.
"""
function add_waypoint!(params::TripParams, index::Integer)
    @assert index >= 1 "Julia uses 1-based indexing"
    _call_with_error() do error_ptr
        CWrapper.osrmc_trip_params_add_waypoint(params.ptr, Csize_t(index - 1), _error_ptr(error_ptr))
        nothing
    end
    return params
end

# Tile service fields are listed together to emphasize the shared XYZ contract.

"""
    set_x!(params::TileParams, x)

Updates the tile's X index in-place so map renderers can reuse the same request
object while panning horizontally.
"""
function set_x!(params::TileParams, x::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_tile_params_set_x(params.ptr, Cuint(x), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_y!(params::TileParams, y)

Companion to `set_x!`; keeps vertical tile changes allocation-free.
"""
function set_y!(params::TileParams, y::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_tile_params_set_y(params.ptr, Cuint(y), _error_ptr(error_ptr))
        nothing
    end
    return params
end

"""
    set_z!(params::TileParams, z)

Adjusts the zoom level without rebuilding the tile request, which keeps map
overlays snappy when zooming.
"""
function set_z!(params::TileParams, z::Integer)
    _call_with_error() do error_ptr
        CWrapper.osrmc_tile_params_set_z(params.ptr, Cuint(z), _error_ptr(error_ptr))
        nothing
    end
    return params
end

end # module Params
