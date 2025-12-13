module Tables

using CEnum
using ..OpenSourceRoutingMachine:
    # modules
    libosrmc,
    # types
    OSRM,
    Position,
    # enums
    OutputFormat, output_format_json, output_format_flatbuffers,
    Approach,
    Snapping,
    # error helpers
    with_error, error_pointer, check_error,
    # string helpers
    as_cstring, as_cstring_or_null,
    # finalize helpers
    finalize,
    # data access helpers
    as_string, as_vector,
    # response getters
    get_json, get_flatbuffer,
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
    set_snapping!,
    # response getters
    get_json,
    get_flatbuffer

using JSON: JSON

"""
    TableAnnotations

Bit flags for selecting which annotations to include in table/matrix responses. Values can be combined using bitwise OR (`|`).

The enum values correspond to bit positions:
- `table_annotations_none = 0`: No annotations
- `table_annotations_duration = 1` (bit 0): Request duration annotations
- `table_annotations_distance = 2` (bit 1): Request distance annotations
- `table_annotations_all = 3`: All annotations (table_annotations_duration | table_annotations_distance)
"""
@cenum(
    TableAnnotations::Int32, begin
        table_annotations_none = 0
        table_annotations_duration = 1
        table_annotations_distance = 2
        table_annotations_all = 3  # table_annotations_duration | table_annotations_distance
    end
)

"""
    TableFallbackCoordinate

Controls whether fallback results use input coordinates or snapped coordinates (`table_fallback_coordinate_input`, `table_fallback_coordinate_snapped`).
"""
@cenum(
    TableFallbackCoordinate::Int32, begin
        table_fallback_coordinate_input = 0
        table_fallback_coordinate_snapped = 1
    end
)

include("response.jl")
include("params.jl")

"""
    table_response(osrm::OSRM, params::TableParams) -> TableResponse

Calls the libosrm Table module and returns the response as a TableResponse object.
"""
function table_response(osrm::OSRM, params::TableParams)::TableResponse
    ptr = with_error() do err
        ccall((:osrmc_table, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm.ptr, params.ptr, error_pointer(err))
    end
    response = TableResponse(ptr)
    return response
end

"""
    table(osrm::OSRM, params::TableParams) -> Union{String, Vector{UInt8}}

Calls the libosrm Table module and returns the response as either JSON or FlatBuffers.
"""
function table(osrm::OSRM, params::TableParams; deserialize::Bool = true)
    response = table_response(osrm, params)
    format = get_format(response)
    return if format == output_format_json
        if deserialize
            return JSON.parse(get_json(response))
        else
            return get_json(response)
        end
    elseif format == output_format_flatbuffers
        if deserialize
            return as_struct(get_flatbuffer(response))
        else
            return get_flatbuffer(response)
        end
    else
        error("Invalid output format: $format")
    end
end

## Parameter setter exports
export
    TableParams,
    TableAnnotations,
    TableFallbackCoordinate,
    set_format!,
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

## compute response exports
export table_response

## Response getter exports
export TableResponse,
    get_format,
    get_json,
    get_flatbuffer

# compute table result exports
export table

end # module Tables
