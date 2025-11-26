module Graph

using ..OpenSourceRoutingMachine: OSRM_jll
using ..Enums: Enums
# OSRM_jll symbols used: osrm_extract_path, osrm_extract, osrm_partition, osrm_customize, osrm_contract

const ProfileType = Enums.Profile.T

export OSRMCommandError,
    profile_lua_path,
    extract,
    partition,
    customize,
    contract

"""
    OSRMCommandError(cmd, exitcode)

Carries the failing command and exit code so build scripts can surface the
exact OSRM CLI error without scraping STDOUT.
"""
struct OSRMCommandError <: Exception
    cmd::Cmd
    exitcode::Int32
end

_profile_symbol(profile::ProfileType) = profile === Enums.Profile.car ? :car :
    profile === Enums.Profile.bicycle ? :bicycle :
    :foot

"""
    profile_lua_path(profile::ProfileType) -> String

Return the absolute path to the Lua profile corresponding to the provided
`Profile` value, even when the artifact relocates files, so callers never hard
code resource paths.
"""
function profile_lua_path(profile::ProfileType)::String
    symbol = _profile_symbol(profile)
    lua_field = Symbol(string(symbol), "_lua")

    if hasproperty(OSRM_jll, lua_field)
        lua_path = getproperty(OSRM_jll, lua_field)
        if !isempty(lua_path) && isfile(lua_path)
            return lua_path
        end
    end

    artifact_dir = dirname(dirname(OSRM_jll.osrm_extract_path))
    candidate = joinpath(artifact_dir, "profiles", string(symbol) * ".lua")
    isfile(candidate) || error("Could not find Lua profile for $(symbol): looked in artifact at $candidate")
    return candidate
end

const _CMD_WINDOWS_VERBATIM = UInt32(0x01)
const _CMD_WINDOWS_HIDE = UInt32(0x02)

_cmd_dir(cmd::Cmd) = isempty(cmd.dir) ? nothing : cmd.dir
_cmd_flag(cmd::Cmd, flag::UInt32) = (cmd.flags & flag) != 0

function _command_with_args(base_cmd::Cmd, args::Vector{String})
    exec = vcat(copy(base_cmd.exec), args)
    cmd = Cmd(exec)
    dir = _cmd_dir(base_cmd)
    kwargs = (
        ignorestatus = base_cmd.ignorestatus,
        env = base_cmd.env,
        cpus = base_cmd.cpus,
        windows_verbatim = _cmd_flag(base_cmd, _CMD_WINDOWS_VERBATIM),
        windows_hide = _cmd_flag(base_cmd, _CMD_WINDOWS_HIDE),
    )
    return dir === nothing ?
        Cmd(cmd; kwargs...) :
        Cmd(cmd; dir = dir, kwargs...)
end

function _run_or_throw(cmd::Cmd)
    proc = run(cmd; wait = false)
    wait(proc)
    success(proc) || throw(OSRMCommandError(cmd, proc.exitcode))
    return proc
end

function extract_cmd(
        osm_path::AbstractString;
        profile::ProfileType = Enums.Profile.car,
        extra_args::Vector{String} = String[]
    )
    profile_path = profile_lua_path(profile)
    args = String["-p", profile_path, osm_path]
    append!(args, extra_args)
    return _command_with_args(OSRM_jll.osrm_extract(), args)
end

function partition_cmd(osrm_base::AbstractString; extra_args::Vector{String} = String[])
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return _command_with_args(OSRM_jll.osrm_partition(), args)
end

function customize_cmd(osrm_base::AbstractString; extra_args::Vector{String} = String[])
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return _command_with_args(OSRM_jll.osrm_customize(), args)
end

function contract_cmd(osrm_base::AbstractString; extra_args::Vector{String} = String[])
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return _command_with_args(OSRM_jll.osrm_contract(), args)
end

"""
    extract(osm_path; profile=Profile.car, extra_args=String[])

Runs the bundled `osrm-extract` with the correct Lua profile, ensuring graph
builds behave the same on every machine.

OSRM 6.0 automatically creates output files based on the input file name in the
same directory as the input file.
"""
function extract(
        osm_path::AbstractString;
        profile::ProfileType = Enums.Profile.car,
        extra_args::Vector{String} = String[]
    )
    cmd = extract_cmd(osm_path; profile = profile, extra_args = extra_args)
    _run_or_throw(cmd)
end

"""
    partition(osrm_base; extra_args=String[])

Executes `osrm-partition` so MLD preparations stay in Julia scripts rather than
shell pipelines.
"""
function partition(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[]
    )
    cmd = partition_cmd(osrm_base; extra_args = extra_args)
    _run_or_throw(cmd)
end

"""
    customize(osrm_base; extra_args=String[])

Calls `osrm-customize` to finish MLD setup, keeping the artifact-provided
binary and flags centralized.
"""
function customize(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[]
    )
    cmd = customize_cmd(osrm_base; extra_args = extra_args)
    _run_or_throw(cmd)
end

"""
    contract(osrm_base; extra_args=String[])

Wraps `osrm-contract` so CH pipelines can be triggered from Julia without
invoking shell scripts manually.
"""
function contract(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[]
    )
    cmd = contract_cmd(osrm_base; extra_args = extra_args)
    _run_or_throw(cmd)
end


end
