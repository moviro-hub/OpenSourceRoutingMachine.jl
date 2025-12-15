"""
    OSRMCommandError(cmd, exitcode)

Carries the failing command and exit code so build scripts can surface the exact
OSRM CLI error without scraping STDOUT.
"""
struct OSRMCommandError <: Exception
    cmd::Cmd
    exitcode::Int32
end

"""
    profile_path(profile::Profile) -> String

Return the absolute path to the Lua profile corresponding to the provided
`Profile` value, even when the artifact relocates files, so callers never hard
code resource paths.
"""
function profile_path(profile::Profile)::String
    lua_field = Symbol(Symbol(profile), :_lua)
    if hasproperty(OSRM_jll, lua_field)
        lua_path = getproperty(OSRM_jll, lua_field)
        if !isempty(lua_path) && isfile(lua_path)
            return lua_path
        end
    end

    # Convert PROFILE_CAR -> car, PROFILE_BICYCLE -> bicycle, PROFILE_FOOT -> foot
    profile_name = lowercase(replace(string(profile), "PROFILE_" => ""))
    artifact_dir = dirname(dirname(OSRM_jll.osrm_extract_path))
    candidate = joinpath(artifact_dir, "profiles", profile_name * ".lua")
    isfile(candidate) || error("Could not find Lua profile for $(string(profile)): looked in artifact at $candidate")
    return candidate
end

function command_with_args(base_cmd::Cmd, args::Vector{String})
    exec = vcat(copy(base_cmd.exec), args)
    cmd = Cmd(exec)
    dir = isempty(base_cmd.dir) ? nothing : base_cmd.dir
    kwargs = (
        ignorestatus = base_cmd.ignorestatus,
        env = base_cmd.env,
        cpus = base_cmd.cpus,
    )
    return dir === nothing ?
        Cmd(cmd; kwargs...) :
        Cmd(cmd; dir = dir, kwargs...)
end

function run_or_throw(cmd::Cmd)
    proc = run(cmd; wait = false)
    wait(proc)
    success(proc) || throw(OSRMCommandError(cmd, proc.exitcode))
    return proc
end
