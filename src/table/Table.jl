module Table

using CEnum
using ..OpenSourceRoutingMachine:
    # modules
    libosrmc,
    # types
    OSRM,
    Position,
    OSRMError,
    # enums
    Approach,
    Snapping,
    # error helpers
    with_error, error_pointer, check_error,
    # string helpers
    as_cstring_or_null,
    # finalize helpers
    finalize,
    # response deserializers
    as_struct

import ..OpenSourceRoutingMachine:
    # parameters
    add_source!,
    add_destination!,
    set_annotations!,
    set_fallback_speed!,
    set_fallback_coordinate_type!,
    set_scale_factor!,
    add_coordinate!,
    add_coordinate_with!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!

"""
    TableAnnotations

Bit flags for selecting which annotations to include in table/matrix responses. Values can be combined using bitwise OR (`|`).

The enum values correspond to bit positions:
- `TABLE_ANNOTATIONS_NONE = 0`: No annotations
- `TABLE_ANNOTATIONS_DURATION = 1` (bit 0): Request duration annotations
- `TABLE_ANNOTATIONS_DISTANCE = 2` (bit 1): Request distance annotations
- `TABLE_ANNOTATIONS_ALL = 3`: All annotations (TABLE_ANNOTATIONS_DURATION | TABLE_ANNOTATIONS_DISTANCE)
"""
@cenum(
    TableAnnotations::Int32, begin
        TABLE_ANNOTATIONS_NONE = 0
        TABLE_ANNOTATIONS_DURATION = 1
        TABLE_ANNOTATIONS_DISTANCE = 2
        TABLE_ANNOTATIONS_ALL = 3  # TABLE_ANNOTATIONS_DURATION | TABLE_ANNOTATIONS_DISTANCE
    end
)

"""
    TableFallbackCoordinate

Controls whether fallback results use input coordinates or snapped coordinates (`TABLE_FALLBACK_COORDINATE_INPUT`, `TABLE_FALLBACK_COORDINATE_SNAPPED`).
"""
@cenum(
    TableFallbackCoordinate::Int32, begin
        TABLE_FALLBACK_COORDINATE_INPUT = 0
        TABLE_FALLBACK_COORDINATE_SNAPPED = 1
    end
)

include("response.jl")
include("params.jl")

"""
    table_response(osrm::OSRM, params::TableParams) -> TableResponse

Call Table service and return response object.
"""
function table_response(osrm::OSRM, params::TableParams)::TableResponse
    ptr = with_error() do err
        ccall((:osrmc_table, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = TableResponse(ptr)
    return response
end

"""
    table(osrm::OSRM, params::TableParams) -> Union{FBResult, Vector{UInt8}}

Call Table service and return FlatBuffers response.
"""
function table(osrm::OSRM, params::TableParams; deserialize::Bool = true)
    response = table_response(osrm, params)
    # Always use zero-copy FlatBuffer transfer
    fb_data = get_flatbuffer(response)
    return deserialize ? as_struct(fb_data) : fb_data
end

## Parameter setter exports
export
    TableParams,
    TableAnnotations,
    TableFallbackCoordinate,
    add_source!,
    add_destination!,
    set_annotations!,
    set_fallback_speed!,
    set_fallback_coordinate_type!,
    set_scale_factor!,
    add_coordinate!,
    add_coordinate_with!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!

## Parameter getter exports
export
    get_sources,
    get_destinations,
    get_annotations,
    get_fallback_speed,
    get_fallback_coordinate_type,
    get_scale_factor,
    get_coordinates,
    get_hints,
    get_radii,
    get_bearings,
    get_approaches,
    get_coordinates_with,
    get_excludes,
    get_generate_hints,
    get_skip_waypoints,
    get_snapping

## compute response exports
export table_response

## Response getter exports
export TableResponse,
    get_flatbuffer

# compute table result exports
export table

end # module Table
