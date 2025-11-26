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

# Treat every libosrm handle as an opaque pointer; Julia must not assume
# layouts because libosrmc owns allocation and lifetime.
const osrmc_error_t = Ptr{Cvoid}
const osrmc_config_t = Ptr{Cvoid}
const osrmc_osrm_t = Ptr{Cvoid}
const osrmc_params_t = Ptr{Cvoid}
const osrmc_blob_t = Ptr{Cvoid}
const osrmc_route_params_t = Ptr{Cvoid}
const osrmc_table_params_t = Ptr{Cvoid}
const osrmc_nearest_params_t = Ptr{Cvoid}
const osrmc_match_params_t = Ptr{Cvoid}
const osrmc_trip_params_t = Ptr{Cvoid}
const osrmc_tile_params_t = Ptr{Cvoid}
const osrmc_route_response_t = Ptr{Cvoid}
const osrmc_table_response_t = Ptr{Cvoid}
const osrmc_nearest_response_t = Ptr{Cvoid}
const osrmc_match_response_t = Ptr{Cvoid}
const osrmc_trip_response_t = Ptr{Cvoid}
const osrmc_tile_response_t = Ptr{Cvoid}

# route_with expects a raw function pointer; keep a type alias so the higher
# layers stay readable and we can document the ABI once.
const osrmc_waypoint_handler_t = Ptr{Cvoid}

# Version helpers let callers confirm the libosrmc build before touching any
# stateful API (useful for pre-flight compatibility checks).
function osrmc_get_version()
    ccall((:osrmc_get_version, libosrmc), Cuint, ())
end # module CWrapper

function osrmc_is_abi_compatible()
    ccall((:osrmc_is_abi_compatible, libosrmc), Cint, ())
end

# libosrmc returns heap-allocated error handles; wrapping the accessors in Julia
# makes it harder to leak or mis-handle them higher up the stack.
function osrmc_error_code(error::osrmc_error_t)
    ccall((:osrmc_error_code, libosrmc), Cstring, (osrmc_error_t,), error)
end

function osrmc_error_message(error::osrmc_error_t)
    ccall((:osrmc_error_message, libosrmc), Cstring, (osrmc_error_t,), error)
end

function osrmc_error_destruct(error::osrmc_error_t)
    ccall((:osrmc_error_destruct, libosrmc), Cvoid, (osrmc_error_t,), error)
end

# Mirror the config and OSRM constructor APIs exactly so higher-level wrappers
# can stay allocation-free and rely on libosrmc for validation.
function osrmc_config_construct(base_path::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_construct, libosrmc), osrmc_config_t, (Cstring, Ptr{osrmc_error_t}), base_path, error)
end

function osrmc_config_destruct(config::osrmc_config_t)
    ccall((:osrmc_config_destruct, libosrmc), Cvoid, (osrmc_config_t,), config)
end

function osrmc_config_set_algorithm(config::osrmc_config_t, algorithm::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_algorithm, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, algorithm, error)
end

function osrmc_config_set_max_locations_trip(config::osrmc_config_t, max_locations::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_locations_trip, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_locations, error)
end

function osrmc_config_set_max_locations_viaroute(config::osrmc_config_t, max_locations::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_locations_viaroute, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_locations, error)
end

function osrmc_config_set_max_locations_distance_table(config::osrmc_config_t, max_locations::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_locations_distance_table, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_locations, error)
end

function osrmc_config_set_max_locations_map_matching(config::osrmc_config_t, max_locations::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_locations_map_matching, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_locations, error)
end

function osrmc_config_set_max_radius_map_matching(config::osrmc_config_t, max_radius::Cdouble, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_radius_map_matching, libosrmc), Cvoid, (osrmc_config_t, Cdouble, Ptr{osrmc_error_t}), config, max_radius, error)
end

function osrmc_config_set_max_results_nearest(config::osrmc_config_t, max_results::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_results_nearest, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_results, error)
end

function osrmc_config_set_default_radius(config::osrmc_config_t, default_radius::Cdouble, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_default_radius, libosrmc), Cvoid, (osrmc_config_t, Cdouble, Ptr{osrmc_error_t}), config, default_radius, error)
end

function osrmc_config_set_max_alternatives(config::osrmc_config_t, max_alternatives::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_max_alternatives, libosrmc), Cvoid, (osrmc_config_t, Cint, Ptr{osrmc_error_t}), config, max_alternatives, error)
end

function osrmc_config_set_use_mmap(config::osrmc_config_t, use_mmap::Bool, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_use_mmap, libosrmc), Cvoid, (osrmc_config_t, Bool, Ptr{osrmc_error_t}), config, use_mmap, error)
end

function osrmc_config_set_dataset_name(config::osrmc_config_t, dataset_name::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_dataset_name, libosrmc), Cvoid, (osrmc_config_t, Cstring, Ptr{osrmc_error_t}), config, dataset_name, error)
end

function osrmc_config_set_use_shared_memory(config::osrmc_config_t, use_shared_memory::Bool, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_use_shared_memory, libosrmc), Cvoid, (osrmc_config_t, Bool, Ptr{osrmc_error_t}), config, use_shared_memory, error)
end

function osrmc_config_set_memory_file(config::osrmc_config_t, memory_file::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_memory_file, libosrmc), Cvoid, (osrmc_config_t, Cstring, Ptr{osrmc_error_t}), config, memory_file, error)
end

function osrmc_config_set_verbosity(config::osrmc_config_t, verbosity::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_set_verbosity, libosrmc), Cvoid, (osrmc_config_t, Cstring, Ptr{osrmc_error_t}), config, verbosity, error)
end

function osrmc_config_disable_feature_dataset(config::osrmc_config_t, dataset_name::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_disable_feature_dataset, libosrmc), Cvoid, (osrmc_config_t, Cstring, Ptr{osrmc_error_t}), config, dataset_name, error)
end

function osrmc_config_clear_disabled_feature_datasets(config::osrmc_config_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_config_clear_disabled_feature_datasets, libosrmc), Cvoid, (osrmc_config_t, Ptr{osrmc_error_t}), config, error)
end

function osrmc_osrm_construct(config::osrmc_config_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_osrm_construct, libosrmc), osrmc_osrm_t, (osrmc_config_t, Ptr{osrmc_error_t}), config, error)
end

function osrmc_osrm_destruct(osrm::osrmc_osrm_t)
    ccall((:osrmc_osrm_destruct, libosrmc), Cvoid, (osrmc_osrm_t,), osrm)
end

# These generic parameter helpers operate on the common osrmc_params_t layout
# so each service-specific params struct can share the same underlying calls.
function osrmc_params_add_coordinate(params::osrmc_params_t, longitude::Cfloat, latitude::Cfloat, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_add_coordinate, libosrmc), Cvoid, (osrmc_params_t, Cfloat, Cfloat, Ptr{osrmc_error_t}), params, longitude, latitude, error)
end

function osrmc_params_add_coordinate_with(params::osrmc_params_t, longitude::Cfloat, latitude::Cfloat, radius::Cfloat, bearing::Cint, range::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_add_coordinate_with, libosrmc), Cvoid, (osrmc_params_t, Cfloat, Cfloat, Cfloat, Cint, Cint, Ptr{osrmc_error_t}), params, longitude, latitude, radius, bearing, range, error)
end

function osrmc_params_set_hint(params::osrmc_params_t, coordinate_index::Csize_t, hint::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_hint, libosrmc), Cvoid, (osrmc_params_t, Csize_t, Cstring, Ptr{osrmc_error_t}), params, coordinate_index, hint, error)
end

function osrmc_params_set_radius(params::osrmc_params_t, coordinate_index::Csize_t, radius::Cdouble, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_radius, libosrmc), Cvoid, (osrmc_params_t, Csize_t, Cdouble, Ptr{osrmc_error_t}), params, coordinate_index, radius, error)
end

function osrmc_params_set_bearing(params::osrmc_params_t, coordinate_index::Csize_t, value::Cint, range::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_bearing, libosrmc), Cvoid, (osrmc_params_t, Csize_t, Cint, Cint, Ptr{osrmc_error_t}), params, coordinate_index, value, range, error)
end

function osrmc_params_set_approach(params::osrmc_params_t, coordinate_index::Csize_t, approach::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_approach, libosrmc), Cvoid, (osrmc_params_t, Csize_t, Cint, Ptr{osrmc_error_t}), params, coordinate_index, approach, error)
end

function osrmc_params_add_exclude(params::osrmc_params_t, exclude_profile::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_add_exclude, libosrmc), Cvoid, (osrmc_params_t, Cstring, Ptr{osrmc_error_t}), params, exclude_profile, error)
end

function osrmc_params_set_generate_hints(params::osrmc_params_t, on::Cint)
    ccall((:osrmc_params_set_generate_hints, libosrmc), Cvoid, (osrmc_params_t, Cint), params, on)
end

function osrmc_params_set_skip_waypoints(params::osrmc_params_t, on::Cint)
    ccall((:osrmc_params_set_skip_waypoints, libosrmc), Cvoid, (osrmc_params_t, Cint), params, on)
end

function osrmc_params_set_snapping(params::osrmc_params_t, snapping::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_snapping, libosrmc), Cvoid, (osrmc_params_t, Cint, Ptr{osrmc_error_t}), params, snapping, error)
end

function osrmc_params_set_format(params::osrmc_params_t, format::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_params_set_format, libosrmc), Cvoid, (osrmc_params_t, Cint, Ptr{osrmc_error_t}), params, format, error)
end

# Route service wrappers stay grouped so the high-level `route.jl` code can map
# directly onto the libosrm REST naming without hunting for ccalls.
function osrmc_route_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_construct, libosrmc), osrmc_route_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_route_params_destruct(params::osrmc_route_params_t)
    ccall((:osrmc_route_params_destruct, libosrmc), Cvoid, (osrmc_route_params_t,), params)
end

function osrmc_route_params_add_steps(params::osrmc_route_params_t, on::Cint)
    ccall((:osrmc_route_params_add_steps, libosrmc), Cvoid, (osrmc_route_params_t, Cint), params, on)
end

function osrmc_route_params_add_alternatives(params::osrmc_route_params_t, on::Cint)
    ccall((:osrmc_route_params_add_alternatives, libosrmc), Cvoid, (osrmc_route_params_t, Cint), params, on)
end

function osrmc_route_params_set_geometries(params::osrmc_route_params_t, geometries::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_set_geometries, libosrmc), Cvoid, (osrmc_route_params_t, Cstring, Ptr{osrmc_error_t}), params, geometries, error)
end

function osrmc_route_params_set_overview(params::osrmc_route_params_t, overview::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_set_overview, libosrmc), Cvoid, (osrmc_route_params_t, Cstring, Ptr{osrmc_error_t}), params, overview, error)
end

function osrmc_route_params_set_continue_straight(params::osrmc_route_params_t, on::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_set_continue_straight, libosrmc), Cvoid, (osrmc_route_params_t, Cint, Ptr{osrmc_error_t}), params, on, error)
end

function osrmc_route_params_set_number_of_alternatives(params::osrmc_route_params_t, count::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_set_number_of_alternatives, libosrmc), Cvoid, (osrmc_route_params_t, Cuint, Ptr{osrmc_error_t}), params, count, error)
end

function osrmc_route_params_set_annotations(params::osrmc_route_params_t, annotations::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_set_annotations, libosrmc), Cvoid, (osrmc_route_params_t, Cstring, Ptr{osrmc_error_t}), params, annotations, error)
end

function osrmc_route_params_add_waypoint(params::osrmc_route_params_t, index::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_params_add_waypoint, libosrmc), Cvoid, (osrmc_route_params_t, Csize_t, Ptr{osrmc_error_t}), params, index, error)
end

function osrmc_route_params_clear_waypoints(params::osrmc_route_params_t)
    ccall((:osrmc_route_params_clear_waypoints, libosrmc), Cvoid, (osrmc_route_params_t,), params)
end

function osrmc_route(osrm::osrmc_osrm_t, params::osrmc_route_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route, libosrmc), osrmc_route_response_t, (osrmc_osrm_t, osrmc_route_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_route_with(osrm::osrmc_osrm_t, params::osrmc_route_params_t, handler::osrmc_waypoint_handler_t, data::Ptr{Cvoid}, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_with, libosrmc), Cvoid, (osrmc_osrm_t, osrmc_route_params_t, osrmc_waypoint_handler_t, Ptr{Cvoid}, Ptr{osrmc_error_t}), osrm, params, handler, data, error)
end

function osrmc_route_response_destruct(response::osrmc_route_response_t)
    ccall((:osrmc_route_response_destruct, libosrmc), Cvoid, (osrmc_route_response_t,), response)
end

function osrmc_route_response_distance(response::osrmc_route_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_distance, libosrmc), Cfloat, (osrmc_route_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_route_response_duration(response::osrmc_route_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_duration, libosrmc), Cfloat, (osrmc_route_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_route_response_alternative_count(response::osrmc_route_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_alternative_count, libosrmc), Cuint, (osrmc_route_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_route_response_distance_at(response::osrmc_route_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_distance_at, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_route_response_duration_at(response::osrmc_route_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_duration_at, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_route_response_geometry_polyline(response::osrmc_route_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_geometry_polyline, libosrmc), Cstring, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_route_response_geometry_coordinate_count(response::osrmc_route_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_geometry_coordinate_count, libosrmc), Cuint, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_route_response_geometry_coordinate_latitude(response::osrmc_route_response_t, route_index::Cuint, coord_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_geometry_coordinate_latitude, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, coord_index, error)
end

function osrmc_route_response_geometry_coordinate_longitude(response::osrmc_route_response_t, route_index::Cuint, coord_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_geometry_coordinate_longitude, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, coord_index, error)
end

function osrmc_route_response_waypoint_count(response::osrmc_route_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_waypoint_count, libosrmc), Cuint, (osrmc_route_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_route_response_waypoint_latitude(response::osrmc_route_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_waypoint_latitude, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_route_response_waypoint_longitude(response::osrmc_route_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_waypoint_longitude, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_route_response_waypoint_name(response::osrmc_route_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_waypoint_name, libosrmc), Cstring, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_route_response_leg_count(response::osrmc_route_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_leg_count, libosrmc), Cuint, (osrmc_route_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_route_response_step_count(response::osrmc_route_response_t, route_index::Cuint, leg_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_step_count, libosrmc), Cuint, (osrmc_route_response_t, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, leg_index, error)
end

function osrmc_route_response_step_distance(response::osrmc_route_response_t, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_step_distance, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_step_duration(response::osrmc_route_response_t, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_step_duration, libosrmc), Cfloat, (osrmc_route_response_t, Cuint, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_step_instruction(response::osrmc_route_response_t, route_index::Cuint, leg_index::Cuint, step_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_step_instruction, libosrmc), Cstring, (osrmc_route_response_t, Cuint, Cuint, Cuint, Ptr{osrmc_error_t}), response, route_index, leg_index, step_index, error)
end

function osrmc_route_response_json(response::osrmc_route_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_route_response_json, libosrmc), osrmc_blob_t, (osrmc_route_response_t, Ptr{osrmc_error_t}), response, error)
end

# Table service coverage mirrors the OSRM HTTP `table` endpoint naming so we
# can document the translation once in the high-level module.
function osrmc_table_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_construct, libosrmc), osrmc_table_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_table_params_destruct(params::osrmc_table_params_t)
    ccall((:osrmc_table_params_destruct, libosrmc), Cvoid, (osrmc_table_params_t,), params)
end

function osrmc_table_params_add_source(params::osrmc_table_params_t, index::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_add_source, libosrmc), Cvoid, (osrmc_table_params_t, Csize_t, Ptr{osrmc_error_t}), params, index, error)
end

function osrmc_table_params_add_destination(params::osrmc_table_params_t, index::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_add_destination, libosrmc), Cvoid, (osrmc_table_params_t, Csize_t, Ptr{osrmc_error_t}), params, index, error)
end

function osrmc_table_params_set_annotations_mask(params::osrmc_table_params_t, annotations::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_set_annotations_mask, libosrmc), Cvoid, (osrmc_table_params_t, Cstring, Ptr{osrmc_error_t}), params, annotations, error)
end

function osrmc_table_params_set_fallback_speed(params::osrmc_table_params_t, speed::Cdouble, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_set_fallback_speed, libosrmc), Cvoid, (osrmc_table_params_t, Cdouble, Ptr{osrmc_error_t}), params, speed, error)
end

function osrmc_table_params_set_fallback_coordinate_type(params::osrmc_table_params_t, coord_type::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_set_fallback_coordinate_type, libosrmc), Cvoid, (osrmc_table_params_t, Cstring, Ptr{osrmc_error_t}), params, coord_type, error)
end

function osrmc_table_params_set_scale_factor(params::osrmc_table_params_t, scale_factor::Cdouble, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_params_set_scale_factor, libosrmc), Cvoid, (osrmc_table_params_t, Cdouble, Ptr{osrmc_error_t}), params, scale_factor, error)
end

function osrmc_table(osrm::osrmc_osrm_t, params::osrmc_table_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table, libosrmc), osrmc_table_response_t, (osrmc_osrm_t, osrmc_table_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_table_response_destruct(response::osrmc_table_response_t)
    ccall((:osrmc_table_response_destruct, libosrmc), Cvoid, (osrmc_table_response_t,), response)
end

function osrmc_table_response_duration(response::osrmc_table_response_t, from::Culong, to::Culong, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_duration, libosrmc), Cfloat, (osrmc_table_response_t, Culong, Culong, Ptr{osrmc_error_t}), response, from, to, error)
end

function osrmc_table_response_distance(response::osrmc_table_response_t, from::Culong, to::Culong, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_distance, libosrmc), Cfloat, (osrmc_table_response_t, Culong, Culong, Ptr{osrmc_error_t}), response, from, to, error)
end

function osrmc_table_response_source_count(response::osrmc_table_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_source_count, libosrmc), Cuint, (osrmc_table_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_table_response_destination_count(response::osrmc_table_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_destination_count, libosrmc), Cuint, (osrmc_table_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_table_response_get_duration_matrix(response::osrmc_table_response_t, matrix::Ptr{Cfloat}, max_size::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_get_duration_matrix, libosrmc), Cint, (osrmc_table_response_t, Ptr{Cfloat}, Csize_t, Ptr{osrmc_error_t}), response, matrix, max_size, error)
end

function osrmc_table_response_get_distance_matrix(response::osrmc_table_response_t, matrix::Ptr{Cfloat}, max_size::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_get_distance_matrix, libosrmc), Cint, (osrmc_table_response_t, Ptr{Cfloat}, Csize_t, Ptr{osrmc_error_t}), response, matrix, max_size, error)
end

function osrmc_table_response_json(response::osrmc_table_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_table_response_json, libosrmc), osrmc_blob_t, (osrmc_table_response_t, Ptr{osrmc_error_t}), response, error)
end

# Nearest service wrappers expose the small response helpers that OSRM omits
# from JSON, which keeps the Julia API competitive with the HTTP version.
function osrmc_nearest_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_params_construct, libosrmc), osrmc_nearest_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_nearest_params_destruct(params::osrmc_nearest_params_t)
    ccall((:osrmc_nearest_params_destruct, libosrmc), Cvoid, (osrmc_nearest_params_t,), params)
end

function osrmc_nearest_set_number_of_results(params::osrmc_nearest_params_t, n::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_set_number_of_results, libosrmc), Cvoid, (osrmc_nearest_params_t, Cuint, Ptr{osrmc_error_t}), params, n, error)
end

function osrmc_nearest(osrm::osrmc_osrm_t, params::osrmc_nearest_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest, libosrmc), osrmc_nearest_response_t, (osrmc_osrm_t, osrmc_nearest_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_nearest_response_destruct(response::osrmc_nearest_response_t)
    ccall((:osrmc_nearest_response_destruct, libosrmc), Cvoid, (osrmc_nearest_response_t,), response)
end

function osrmc_nearest_response_count(response::osrmc_nearest_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_count, libosrmc), Cuint, (osrmc_nearest_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_nearest_response_latitude(response::osrmc_nearest_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_latitude, libosrmc), Cfloat, (osrmc_nearest_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_nearest_response_longitude(response::osrmc_nearest_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_longitude, libosrmc), Cfloat, (osrmc_nearest_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_nearest_response_name(response::osrmc_nearest_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_name, libosrmc), Cstring, (osrmc_nearest_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_nearest_response_distance(response::osrmc_nearest_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_distance, libosrmc), Cfloat, (osrmc_nearest_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_nearest_response_json(response::osrmc_nearest_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_nearest_response_json, libosrmc), osrmc_blob_t, (osrmc_nearest_response_t, Ptr{osrmc_error_t}), response, error)
end

# Map matching wrappers replicate OSRM's streaming interface, giving Julia
# callers the same control over timestamps and tidy modes as the CLI.
function osrmc_match_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_params_construct, libosrmc), osrmc_match_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_match_params_destruct(params::osrmc_match_params_t)
    ccall((:osrmc_match_params_destruct, libosrmc), Cvoid, (osrmc_match_params_t,), params)
end

function osrmc_match_params_add_timestamp(params::osrmc_match_params_t, timestamp::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_params_add_timestamp, libosrmc), Cvoid, (osrmc_match_params_t, Cuint, Ptr{osrmc_error_t}), params, timestamp, error)
end

function osrmc_match_params_set_gaps(params::osrmc_match_params_t, gaps::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_params_set_gaps, libosrmc), Cvoid, (osrmc_match_params_t, Cstring, Ptr{osrmc_error_t}), params, gaps, error)
end

function osrmc_match_params_set_tidy(params::osrmc_match_params_t, on::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_params_set_tidy, libosrmc), Cvoid, (osrmc_match_params_t, Cint, Ptr{osrmc_error_t}), params, on, error)
end

function osrmc_match(osrm::osrmc_osrm_t, params::osrmc_match_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match, libosrmc), osrmc_match_response_t, (osrmc_osrm_t, osrmc_match_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_match_response_destruct(response::osrmc_match_response_t)
    ccall((:osrmc_match_response_destruct, libosrmc), Cvoid, (osrmc_match_response_t,), response)
end

function osrmc_match_response_route_count(response::osrmc_match_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_route_count, libosrmc), Cuint, (osrmc_match_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_match_response_tracepoint_count(response::osrmc_match_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_tracepoint_count, libosrmc), Cuint, (osrmc_match_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_match_response_route_distance(response::osrmc_match_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_route_distance, libosrmc), Cfloat, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_match_response_route_duration(response::osrmc_match_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_route_duration, libosrmc), Cfloat, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_match_response_route_confidence(response::osrmc_match_response_t, route_index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_route_confidence, libosrmc), Cfloat, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, route_index, error)
end

function osrmc_match_response_tracepoint_latitude(response::osrmc_match_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_tracepoint_latitude, libosrmc), Cfloat, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_match_response_tracepoint_longitude(response::osrmc_match_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_tracepoint_longitude, libosrmc), Cfloat, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_match_response_tracepoint_is_null(response::osrmc_match_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_tracepoint_is_null, libosrmc), Cint, (osrmc_match_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_match_response_json(response::osrmc_match_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_match_response_json, libosrmc), osrmc_blob_t, (osrmc_match_response_t, Ptr{osrmc_error_t}), response, error)
end

# Trip service helpers stay in their own section to make it obvious which
# ccalls correspond to OSRM's round-trip optimizer.
function osrmc_trip_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_params_construct, libosrmc), osrmc_trip_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_trip_params_destruct(params::osrmc_trip_params_t)
    ccall((:osrmc_trip_params_destruct, libosrmc), Cvoid, (osrmc_trip_params_t,), params)
end

function osrmc_trip_params_add_roundtrip(params::osrmc_trip_params_t, on::Cint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_params_add_roundtrip, libosrmc), Cvoid, (osrmc_trip_params_t, Cint, Ptr{osrmc_error_t}), params, on, error)
end

function osrmc_trip_params_add_source(params::osrmc_trip_params_t, source::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_params_add_source, libosrmc), Cvoid, (osrmc_trip_params_t, Cstring, Ptr{osrmc_error_t}), params, source, error)
end

function osrmc_trip_params_add_destination(params::osrmc_trip_params_t, destination::Cstring, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_params_add_destination, libosrmc), Cvoid, (osrmc_trip_params_t, Cstring, Ptr{osrmc_error_t}), params, destination, error)
end

function osrmc_trip_params_clear_waypoints(params::osrmc_trip_params_t)
    ccall((:osrmc_trip_params_clear_waypoints, libosrmc), Cvoid, (osrmc_trip_params_t,), params)
end

function osrmc_trip_params_add_waypoint(params::osrmc_trip_params_t, index::Csize_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_params_add_waypoint, libosrmc), Cvoid, (osrmc_trip_params_t, Csize_t, Ptr{osrmc_error_t}), params, index, error)
end

function osrmc_trip(osrm::osrmc_osrm_t, params::osrmc_trip_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip, libosrmc), osrmc_trip_response_t, (osrmc_osrm_t, osrmc_trip_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_trip_response_destruct(response::osrmc_trip_response_t)
    ccall((:osrmc_trip_response_destruct, libosrmc), Cvoid, (osrmc_trip_response_t,), response)
end

function osrmc_trip_response_distance(response::osrmc_trip_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_distance, libosrmc), Cfloat, (osrmc_trip_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_trip_response_duration(response::osrmc_trip_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_duration, libosrmc), Cfloat, (osrmc_trip_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_trip_response_waypoint_count(response::osrmc_trip_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_waypoint_count, libosrmc), Cuint, (osrmc_trip_response_t, Ptr{osrmc_error_t}), response, error)
end

function osrmc_trip_response_waypoint_latitude(response::osrmc_trip_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_waypoint_latitude, libosrmc), Cfloat, (osrmc_trip_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_trip_response_waypoint_longitude(response::osrmc_trip_response_t, index::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_waypoint_longitude, libosrmc), Cfloat, (osrmc_trip_response_t, Cuint, Ptr{osrmc_error_t}), response, index, error)
end

function osrmc_trip_response_json(response::osrmc_trip_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_trip_response_json, libosrmc), osrmc_blob_t, (osrmc_trip_response_t, Ptr{osrmc_error_t}), response, error)
end

# Tile service wrappers expose the low-level vector-tile helpers so we can serve
# map previews without shelling out to osrm-routed.
function osrmc_tile_params_construct(error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_params_construct, libosrmc), osrmc_tile_params_t, (Ptr{osrmc_error_t},), error)
end

function osrmc_tile_params_destruct(params::osrmc_tile_params_t)
    ccall((:osrmc_tile_params_destruct, libosrmc), Cvoid, (osrmc_tile_params_t,), params)
end

function osrmc_tile_params_set_x(params::osrmc_tile_params_t, x::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_params_set_x, libosrmc), Cvoid, (osrmc_tile_params_t, Cuint, Ptr{osrmc_error_t}), params, x, error)
end

function osrmc_tile_params_set_y(params::osrmc_tile_params_t, y::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_params_set_y, libosrmc), Cvoid, (osrmc_tile_params_t, Cuint, Ptr{osrmc_error_t}), params, y, error)
end

function osrmc_tile_params_set_z(params::osrmc_tile_params_t, z::Cuint, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_params_set_z, libosrmc), Cvoid, (osrmc_tile_params_t, Cuint, Ptr{osrmc_error_t}), params, z, error)
end

function osrmc_tile(osrm::osrmc_osrm_t, params::osrmc_tile_params_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile, libosrmc), osrmc_tile_response_t, (osrmc_osrm_t, osrmc_tile_params_t, Ptr{osrmc_error_t}), osrm, params, error)
end

function osrmc_tile_response_destruct(response::osrmc_tile_response_t)
    ccall((:osrmc_tile_response_destruct, libosrmc), Cvoid, (osrmc_tile_response_t,), response)
end

function osrmc_tile_response_data(response::osrmc_tile_response_t, size_ptr::Ptr{Csize_t}, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_response_data, libosrmc), Ptr{Cchar}, (osrmc_tile_response_t, Ptr{Csize_t}, Ptr{osrmc_error_t}), response, size_ptr, error)
end

function osrmc_tile_response_size(response::osrmc_tile_response_t, error::Ptr{osrmc_error_t})
    ccall((:osrmc_tile_response_size, libosrmc), Csize_t, (osrmc_tile_response_t, Ptr{osrmc_error_t}), response, error)
end

# Blob helpers decode the opaque buffers used across multiple services (route,
# table, nearest, etc.), so keeping them centralized avoids subtle lifetime bugs.
function osrmc_blob_data(blob::osrmc_blob_t)
    ccall((:osrmc_blob_data, libosrmc), Ptr{Cchar}, (osrmc_blob_t,), blob)
end

function osrmc_blob_size(blob::osrmc_blob_t)
    ccall((:osrmc_blob_size, libosrmc), Csize_t, (osrmc_blob_t,), blob)
end

function osrmc_blob_destruct(blob::osrmc_blob_t)
    ccall((:osrmc_blob_destruct, libosrmc), Cvoid, (osrmc_blob_t,), blob)
end

end
