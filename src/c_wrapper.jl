"""
Low-level C bindings for libosrmc.
This module provides direct ccall wrappers for all C functions in libosrmc.
"""
module CWrapper

using ..OpenSourceRoutingMachine: libosrmc_jll
using Libdl: dlopen, dlsym, dlsym_e

# Keep a direct pointer to the artifact-managed lib so we never resolve against
# a user-installed libosrmc with a mismatched ABI.
const libosrmc = libosrmc_jll.libosrmc_path

export
    osrmc_get_version,
    osrmc_is_abi_compatible,
    osrmc_error_code,
    osrmc_error_message,
    osrmc_error_destruct,
    osrmc_config_construct,
    osrmc_config_destruct,
    osrmc_config_set_algorithm,
    osrmc_config_set_max_locations_trip,
    osrmc_config_set_max_locations_viaroute,
    osrmc_config_set_max_locations_distance_table,
    osrmc_config_set_max_locations_map_matching,
    osrmc_config_set_max_radius_map_matching,
    osrmc_config_set_max_results_nearest,
    osrmc_config_set_default_radius,
    osrmc_config_set_max_alternatives,
    osrmc_config_set_use_mmap,
    osrmc_config_set_dataset_name,
    osrmc_config_set_use_shared_memory,
    osrmc_config_set_memory_file,
    osrmc_config_set_verbosity,
    osrmc_config_disable_feature_dataset,
    osrmc_config_clear_disabled_feature_datasets,
    osrmc_osrm_construct,
    osrmc_osrm_destruct,
    osrmc_params_add_coordinate,
    osrmc_params_add_coordinate_with,
    osrmc_params_set_hint,
    osrmc_params_set_radius,
    osrmc_params_set_bearing,
    osrmc_params_set_approach,
    osrmc_params_add_exclude,
    osrmc_params_set_generate_hints,
    osrmc_params_set_skip_waypoints,
    osrmc_params_set_snapping,
    osrmc_params_set_format,
    osrmc_route_params_construct,
    osrmc_route_params_destruct,
    osrmc_route_params_add_steps,
    osrmc_route_params_add_alternatives,
    osrmc_route_params_set_geometries,
    osrmc_route_params_set_overview,
    osrmc_route_params_set_continue_straight,
    osrmc_route_params_set_number_of_alternatives,
    osrmc_route_params_set_annotations,
    osrmc_route_params_add_waypoint,
    osrmc_route_params_clear_waypoints,
    osrmc_route,
    osrmc_route_with,
    osrmc_route_response_destruct,
    osrmc_route_response_distance,
    osrmc_route_response_duration,
    osrmc_route_response_alternative_count,
    osrmc_route_response_distance_at,
    osrmc_route_response_duration_at,
    osrmc_route_response_geometry_polyline,
    osrmc_route_response_geometry_coordinate_count,
    osrmc_route_response_geometry_coordinate_latitude,
    osrmc_route_response_geometry_coordinate_longitude,
    osrmc_route_response_waypoint_count,
    osrmc_route_response_waypoint_latitude,
    osrmc_route_response_waypoint_longitude,
    osrmc_route_response_waypoint_name,
    osrmc_route_response_leg_count,
    osrmc_route_response_step_count,
    osrmc_route_response_step_distance,
    osrmc_route_response_step_duration,
    osrmc_route_response_step_instruction,
    osrmc_route_response_json,
    osrmc_table_params_construct,
    osrmc_table_params_destruct,
    osrmc_table_params_add_source,
    osrmc_table_params_add_destination,
    osrmc_table_params_set_annotations_mask,
    osrmc_table_params_set_fallback_speed,
    osrmc_table_params_set_fallback_coordinate_type,
    osrmc_table_params_set_scale_factor,
    osrmc_table,
    osrmc_table_response_destruct,
    osrmc_table_response_duration,
    osrmc_table_response_distance,
    osrmc_table_response_source_count,
    osrmc_table_response_destination_count,
    osrmc_table_response_get_duration_matrix,
    osrmc_table_response_get_distance_matrix,
    osrmc_table_response_json,
    osrmc_nearest_params_construct,
    osrmc_nearest_params_destruct,
    osrmc_nearest_set_number_of_results,
    osrmc_nearest,
    osrmc_nearest_response_destruct,
    osrmc_nearest_response_count,
    osrmc_nearest_response_latitude,
    osrmc_nearest_response_longitude,
    osrmc_nearest_response_name,
    osrmc_nearest_response_distance,
    osrmc_nearest_response_json,
    osrmc_match_params_construct,
    osrmc_match_params_destruct,
    osrmc_match_params_add_timestamp,
    osrmc_match_params_set_gaps,
    osrmc_match_params_set_tidy,
    osrmc_match,
    osrmc_match_response_destruct,
    osrmc_match_response_route_count,
    osrmc_match_response_tracepoint_count,
    osrmc_match_response_route_distance,
    osrmc_match_response_route_duration,
    osrmc_match_response_route_confidence,
    osrmc_match_response_tracepoint_latitude,
    osrmc_match_response_tracepoint_longitude,
    osrmc_match_response_tracepoint_is_null,
    osrmc_match_response_json,
    osrmc_trip_params_construct,
    osrmc_trip_params_destruct,
    osrmc_trip_params_add_roundtrip,
    osrmc_trip_params_add_source,
    osrmc_trip_params_add_destination,
    osrmc_trip_params_clear_waypoints,
    osrmc_trip_params_add_waypoint,
    osrmc_trip,
    osrmc_trip_response_destruct,
    osrmc_trip_response_distance,
    osrmc_trip_response_duration,
    osrmc_trip_response_waypoint_count,
    osrmc_trip_response_waypoint_latitude,
    osrmc_trip_response_waypoint_longitude,
    osrmc_trip_response_json,
    osrmc_tile_params_construct,
    osrmc_tile_params_destruct,
    osrmc_tile_params_set_x,
    osrmc_tile_params_set_y,
    osrmc_tile_params_set_z,
    osrmc_tile,
    osrmc_tile_response_destruct,
    osrmc_tile_response_data,
    osrmc_tile_response_size,
    osrmc_blob_data,
    osrmc_blob_size,
    osrmc_blob_destruct

# Version helpers let callers confirm the libosrmc build before touching any
# stateful API (useful for pre-flight compatibility checks).
function osrmc_get_version()
    return ccall((:osrmc_get_version, libosrmc), Cuint, ())
end # module CWrapper

function osrmc_is_abi_compatible()
    return ccall((:osrmc_is_abi_compatible, libosrmc), Cint, ())
end

# libosrmc returns heap-allocated error handles; wrapping the accessors in Julia
# makes it harder to leak or mis-handle them higher up the stack.
function osrmc_error_code(error::Ptr{Cvoid})
    return ccall((:osrmc_error_code, libosrmc), Cstring, (Ptr{Cvoid},), error)
end

function osrmc_error_message(error::Ptr{Cvoid})
    return ccall((:osrmc_error_message, libosrmc), Cstring, (Ptr{Cvoid},), error)
end

function osrmc_error_destruct(error::Ptr{Cvoid})
    return ccall((:osrmc_error_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), error)
end

# Mirror the config and OSRM constructor APIs exactly so higher-level wrappers
# can stay allocation-free and rely on libosrmc for validation.
function osrmc_config_construct(base_path::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_construct, libosrmc), Ptr{Cvoid}, (Cstring, Ptr{Ptr{Cvoid}}), base_path, error)
end

function osrmc_config_destruct(config::Ptr{Cvoid})
    return ccall((:osrmc_config_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), config)
end

function osrmc_config_set_algorithm(config::Ptr{Cvoid}, algorithm::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_algorithm, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, algorithm, error)
end

function osrmc_config_set_max_locations_trip(config::Ptr{Cvoid}, max_locations::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_locations_trip, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_locations, error)
end

function osrmc_config_set_max_locations_viaroute(config::Ptr{Cvoid}, max_locations::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_locations_viaroute, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_locations, error)
end

function osrmc_config_set_max_locations_distance_table(config::Ptr{Cvoid}, max_locations::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_locations_distance_table, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_locations, error)
end

function osrmc_config_set_max_locations_map_matching(config::Ptr{Cvoid}, max_locations::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_locations_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_locations, error)
end

function osrmc_config_set_max_radius_map_matching(config::Ptr{Cvoid}, max_radius::Cdouble, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_radius_map_matching, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), config, max_radius, error)
end

function osrmc_config_set_max_results_nearest(config::Ptr{Cvoid}, max_results::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_results_nearest, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_results, error)
end

function osrmc_config_set_default_radius(config::Ptr{Cvoid}, default_radius::Cdouble, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_default_radius, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), config, default_radius, error)
end

function osrmc_config_set_max_alternatives(config::Ptr{Cvoid}, max_alternatives::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_max_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), config, max_alternatives, error)
end

function osrmc_config_set_use_mmap(config::Ptr{Cvoid}, use_mmap::Bool, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_use_mmap, libosrmc), Cvoid, (Ptr{Cvoid}, Bool, Ptr{Ptr{Cvoid}}), config, use_mmap, error)
end

function osrmc_config_set_dataset_name(config::Ptr{Cvoid}, dataset_name::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_dataset_name, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config, dataset_name, error)
end

function osrmc_config_set_use_shared_memory(config::Ptr{Cvoid}, use_shared_memory::Bool, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_use_shared_memory, libosrmc), Cvoid, (Ptr{Cvoid}, Bool, Ptr{Ptr{Cvoid}}), config, use_shared_memory, error)
end

function osrmc_config_set_memory_file(config::Ptr{Cvoid}, memory_file::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_memory_file, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config, memory_file, error)
end

function osrmc_config_set_verbosity(config::Ptr{Cvoid}, verbosity::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_set_verbosity, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config, verbosity, error)
end

function osrmc_config_disable_feature_dataset(config::Ptr{Cvoid}, dataset_name::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_disable_feature_dataset, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), config, dataset_name, error)
end

function osrmc_config_clear_disabled_feature_datasets(config::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_config_clear_disabled_feature_datasets, libosrmc), Cvoid, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), config, error)
end

function osrmc_osrm_construct(config::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_osrm_construct, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), config, error)
end

function osrmc_osrm_destruct(osrm::Ptr{Cvoid})
    return ccall((:osrmc_osrm_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), osrm)
end

# These generic parameter helpers operate on the common Ptr{Cvoid} layout
# so each service-specific params struct can share the same underlying calls.
function osrmc_params_add_coordinate(params::Ptr{Cvoid}, longitude::Cfloat, latitude::Cfloat, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_add_coordinate, libosrmc), Cvoid, (Ptr{Cvoid}, Cfloat, Cfloat, Ptr{Ptr{Cvoid}}), params, longitude, latitude, error)
end

function osrmc_params_add_coordinate_with(params::Ptr{Cvoid}, longitude::Cfloat, latitude::Cfloat, radius::Cfloat, bearing::Cint, range::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_add_coordinate_with, libosrmc), Cvoid, (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cint, Cint, Ptr{Ptr{Cvoid}}), params, longitude, latitude, radius, bearing, range, error)
end

function osrmc_params_set_hint(params::Ptr{Cvoid}, coordinate_index::Csize_t, hint::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_hint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Cstring, Ptr{Ptr{Cvoid}}), params, coordinate_index, hint, error)
end

function osrmc_params_set_radius(params::Ptr{Cvoid}, coordinate_index::Csize_t, radius::Cdouble, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_radius, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Cdouble, Ptr{Ptr{Cvoid}}), params, coordinate_index, radius, error)
end

function osrmc_params_set_bearing(params::Ptr{Cvoid}, coordinate_index::Csize_t, value::Cint, range::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_bearing, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Cint, Cint, Ptr{Ptr{Cvoid}}), params, coordinate_index, value, range, error)
end

function osrmc_params_set_approach(params::Ptr{Cvoid}, coordinate_index::Csize_t, approach::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_approach, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Cint, Ptr{Ptr{Cvoid}}), params, coordinate_index, approach, error)
end

function osrmc_params_add_exclude(params::Ptr{Cvoid}, exclude_profile::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_add_exclude, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, exclude_profile, error)
end

function osrmc_params_set_generate_hints(params::Ptr{Cvoid}, on::Cint)
    return ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params, on)
end

function osrmc_params_set_skip_waypoints(params::Ptr{Cvoid}, on::Cint)
    return ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params, on)
end

function osrmc_params_set_snapping(params::Ptr{Cvoid}, snapping::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_snapping, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params, snapping, error)
end

function osrmc_params_set_format(params::Ptr{Cvoid}, format::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_params_set_format, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params, format, error)
end

# Route service wrappers stay grouped so the high-level `route.jl` code can map
# directly onto the libosrm REST naming without hunting for ccalls.
function osrmc_route_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_route_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_route_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_route_params_add_steps(params::Ptr{Cvoid}, on::Cint)
    return ccall((:osrmc_route_params_add_steps, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params, on)
end

function osrmc_route_params_add_alternatives(params::Ptr{Cvoid}, on::Cint)
    return ccall((:osrmc_route_params_add_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cint), params, on)
end

function osrmc_route_params_set_geometries(params::Ptr{Cvoid}, geometries::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_set_geometries, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, geometries, error)
end

function osrmc_route_params_set_overview(params::Ptr{Cvoid}, overview::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_set_overview, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, overview, error)
end

function osrmc_route_params_set_continue_straight(params::Ptr{Cvoid}, on::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_set_continue_straight, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params, on, error)
end

function osrmc_route_params_set_number_of_alternatives(params::Ptr{Cvoid}, count::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_set_number_of_alternatives, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, count, error)
end

function osrmc_route_params_set_annotations(params::Ptr{Cvoid}, annotations::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_set_annotations, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, annotations, error)
end

function osrmc_route_params_add_waypoint(params::Ptr{Cvoid}, index::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params, index, error)
end

function osrmc_route_params_clear_waypoints(params::Ptr{Cvoid})
    return ccall((:osrmc_route_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_route(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_route_with(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, handler::Ptr{Cvoid}, data::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_with, libosrmc), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, handler, data, error)
end

function osrmc_route_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_route_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_route_response_distance(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_route_response_duration(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_duration, libosrmc), Cfloat, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_route_response_alternative_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_alternative_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_route_response_distance_at(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_distance_at, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_route_response_duration_at(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_duration_at, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_route_response_geometry_polyline(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_geometry_polyline, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_route_response_geometry_coordinate_count(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_geometry_coordinate_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_route_response_geometry_coordinate_latitude(response::Ptr{Cvoid}, route_index::Cuint, coord_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_geometry_coordinate_latitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, coord_index, error)
end

function osrmc_route_response_geometry_coordinate_longitude(response::Ptr{Cvoid}, route_index::Cuint, coord_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_geometry_coordinate_longitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, coord_index, error)
end

function osrmc_route_response_waypoint_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_waypoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_route_response_waypoint_latitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_waypoint_latitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_route_response_waypoint_longitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_waypoint_longitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_route_response_waypoint_name(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_waypoint_name, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_route_response_leg_count(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_leg_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_route_response_step_count(response::Ptr{Cvoid}, route_index::Cuint, leg_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_step_count, libosrmc), Cuint, (Ptr{Cvoid}, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, leg_index, error)
end

function osrmc_route_response_step_distance(response::Ptr{Cvoid}, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_step_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_step_duration(response::Ptr{Cvoid}, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_step_duration, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_step_instruction(response::Ptr{Cvoid}, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_step_instruction, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Cuint, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_json(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_route_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Table service coverage mirrors the OSRM HTTP `table` endpoint naming so we
# can document the translation once in the high-level module.
function osrmc_table_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_table_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_table_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_table_params_add_source(params::Ptr{Cvoid}, index::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_add_source, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params, index, error)
end

function osrmc_table_params_add_destination(params::Ptr{Cvoid}, index::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_add_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params, index, error)
end

function osrmc_table_params_set_annotations_mask(params::Ptr{Cvoid}, annotations::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_set_annotations_mask, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, annotations, error)
end

function osrmc_table_params_set_fallback_speed(params::Ptr{Cvoid}, speed::Cdouble, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_set_fallback_speed, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params, speed, error)
end

function osrmc_table_params_set_fallback_coordinate_type(params::Ptr{Cvoid}, coord_type::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_set_fallback_coordinate_type, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, coord_type, error)
end

function osrmc_table_params_set_scale_factor(params::Ptr{Cvoid}, scale_factor::Cdouble, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_params_set_scale_factor, libosrmc), Cvoid, (Ptr{Cvoid}, Cdouble, Ptr{Ptr{Cvoid}}), params, scale_factor, error)
end

function osrmc_table(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_table_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_table_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_table_response_duration(response::Ptr{Cvoid}, from::Culong, to::Culong, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_duration, libosrmc), Cfloat, (Ptr{Cvoid}, Culong, Culong, Ptr{Ptr{Cvoid}}), response, from, to, error)
end

function osrmc_table_response_distance(response::Ptr{Cvoid}, from::Culong, to::Culong, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Culong, Culong, Ptr{Ptr{Cvoid}}), response, from, to, error)
end

function osrmc_table_response_source_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_source_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_table_response_destination_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_destination_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_table_response_get_duration_matrix(response::Ptr{Cvoid}, matrix::Ptr{Cfloat}, max_size::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_get_duration_matrix, libosrmc), Cint, (Ptr{Cvoid}, Ptr{Cfloat}, Csize_t, Ptr{Ptr{Cvoid}}), response, matrix, max_size, error)
end

function osrmc_table_response_get_distance_matrix(response::Ptr{Cvoid}, matrix::Ptr{Cfloat}, max_size::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_get_distance_matrix, libosrmc), Cint, (Ptr{Cvoid}, Ptr{Cfloat}, Csize_t, Ptr{Ptr{Cvoid}}), response, matrix, max_size, error)
end

function osrmc_table_response_json(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_table_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Nearest service wrappers expose the small response helpers that OSRM omits
# from JSON, which keeps the Julia API competitive with the HTTP version.
function osrmc_nearest_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_nearest_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_nearest_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_nearest_set_number_of_results(params::Ptr{Cvoid}, n::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_set_number_of_results, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, n, error)
end

function osrmc_nearest(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_nearest_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_nearest_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_nearest_response_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_nearest_response_latitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_latitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_nearest_response_longitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_longitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_nearest_response_name(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_name, libosrmc), Cstring, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_nearest_response_distance(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_nearest_response_json(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_nearest_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Map matching wrappers replicate OSRM's streaming interface, giving Julia
# callers the same control over timestamps and tidy modes as the CLI.
function osrmc_match_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_match_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_match_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_match_params_add_timestamp(params::Ptr{Cvoid}, timestamp::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_params_add_timestamp, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, timestamp, error)
end

function osrmc_match_params_set_gaps(params::Ptr{Cvoid}, gaps::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_params_set_gaps, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, gaps, error)
end

function osrmc_match_params_set_tidy(params::Ptr{Cvoid}, on::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_params_set_tidy, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params, on, error)
end

function osrmc_match(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_match_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_match_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_match_response_route_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_route_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_match_response_tracepoint_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_tracepoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_match_response_route_distance(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_route_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_match_response_route_duration(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_route_duration, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_match_response_route_confidence(response::Ptr{Cvoid}, route_index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_route_confidence, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, route_index, error)
end

function osrmc_match_response_tracepoint_latitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_tracepoint_latitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_match_response_tracepoint_longitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_tracepoint_longitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_match_response_tracepoint_is_null(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_tracepoint_is_null, libosrmc), Cint, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_match_response_json(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_match_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Trip service helpers stay in their own section to make it obvious which
# ccalls correspond to OSRM's round-trip optimizer.
function osrmc_trip_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_trip_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_trip_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_trip_params_add_roundtrip(params::Ptr{Cvoid}, on::Cint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_params_add_roundtrip, libosrmc), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Ptr{Cvoid}}), params, on, error)
end

function osrmc_trip_params_add_source(params::Ptr{Cvoid}, source::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_params_add_source, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, source, error)
end

function osrmc_trip_params_add_destination(params::Ptr{Cvoid}, destination::Cstring, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_params_add_destination, libosrmc), Cvoid, (Ptr{Cvoid}, Cstring, Ptr{Ptr{Cvoid}}), params, destination, error)
end

function osrmc_trip_params_clear_waypoints(params::Ptr{Cvoid})
    return ccall((:osrmc_trip_params_clear_waypoints, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_trip_params_add_waypoint(params::Ptr{Cvoid}, index::Csize_t, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_params_add_waypoint, libosrmc), Cvoid, (Ptr{Cvoid}, Csize_t, Ptr{Ptr{Cvoid}}), params, index, error)
end

function osrmc_trip(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_trip_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_trip_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_trip_response_distance(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_distance, libosrmc), Cfloat, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_trip_response_duration(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_duration, libosrmc), Cfloat, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_trip_response_waypoint_count(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_waypoint_count, libosrmc), Cuint, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

function osrmc_trip_response_waypoint_latitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_waypoint_latitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_trip_response_waypoint_longitude(response::Ptr{Cvoid}, index::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_waypoint_longitude, libosrmc), Cfloat, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), response, index, error)
end

function osrmc_trip_response_json(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_trip_response_json, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Tile service wrappers expose the low-level vector-tile helpers so we can serve
# map previews without shelling out to osrm-routed.
function osrmc_tile_params_construct(error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_params_construct, libosrmc), Ptr{Cvoid}, (Ptr{Ptr{Cvoid}},), error)
end

function osrmc_tile_params_destruct(params::Ptr{Cvoid})
    return ccall((:osrmc_tile_params_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), params)
end

function osrmc_tile_params_set_x(params::Ptr{Cvoid}, x::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_params_set_x, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, x, error)
end

function osrmc_tile_params_set_y(params::Ptr{Cvoid}, y::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_params_set_y, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, y, error)
end

function osrmc_tile_params_set_z(params::Ptr{Cvoid}, z::Cuint, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_params_set_z, libosrmc), Cvoid, (Ptr{Cvoid}, Cuint, Ptr{Ptr{Cvoid}}), params, z, error)
end

function osrmc_tile(osrm::Ptr{Cvoid}, params::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile, libosrmc), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), osrm, params, error)
end

function osrmc_tile_response_destruct(response::Ptr{Cvoid})
    return ccall((:osrmc_tile_response_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), response)
end

function osrmc_tile_response_data(response::Ptr{Cvoid}, size_ptr::Ptr{Csize_t}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_response_data, libosrmc), Ptr{Cchar}, (Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Ptr{Cvoid}}), response, size_ptr, error)
end

function osrmc_tile_response_size(response::Ptr{Cvoid}, error::Ptr{Ptr{Cvoid}})
    return ccall((:osrmc_tile_response_size, libosrmc), Csize_t, (Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), response, error)
end

# Blob helpers decode the opaque buffers used across multiple services (route,
# table, nearest, etc.), so keeping them centralized avoids subtle lifetime bugs.
function osrmc_blob_data(blob::Ptr{Cvoid})
    return ccall((:osrmc_blob_data, libosrmc), Ptr{Cchar}, (Ptr{Cvoid},), blob)
end

function osrmc_blob_size(blob::Ptr{Cvoid})
    return ccall((:osrmc_blob_size, libosrmc), Csize_t, (Ptr{Cvoid},), blob)
end

function osrmc_blob_destruct(blob::Ptr{Cvoid})
    return ccall((:osrmc_blob_destruct, libosrmc), Cvoid, (Ptr{Cvoid},), blob)
end

end
