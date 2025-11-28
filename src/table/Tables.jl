module Tables

using ..Utils: Utils, with_error, error_pointer, as_cstring, as_cstring_or_null, as_cint, normalize_enum, to_cint
import ..OpenSourceRoutingMachine:
    OSRM, duration, distance, as_json, libosrmc,
    add_source!, add_destination!, set_annotations_mask!, set_fallback_speed!,
    set_fallback_coordinate_type!, set_scale_factor!,
    add_coordinate!, add_coordinate_with!, set_hint!, set_radius!, set_bearing!,
    set_approach!, add_exclude!, set_generate_hints!, set_skip_waypoints!,
    set_snapping!, set_format!, LatLon, Approach, Snapping, OutputFormat

include("response.jl")
include("params.jl")

"""
    table(osrm::OSRM, params::TableParams) -> TableResponse

Calls libosrmc's Table endpoint directly, keeping the full response in-memory
instead of going through osrm-routed.
"""
function table(osrm::OSRM, params::TableParams)
    ptr = with_error() do err
        ccall((:osrmc_table, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    return TableResponse(ptr)
end

export
    TableResponse,
    TableParams,
    table,
    as_json,
    source_count,
    destination_count,
    duration,
    distance,
    duration_matrix,
    distance_matrix,
    add_source!,
    add_destination!,
    set_annotations_mask!,
    set_fallback_speed!,
    set_fallback_coordinate_type!,
    set_scale_factor!

end # module Tables
