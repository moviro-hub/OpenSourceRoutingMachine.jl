function customize_cmd(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_customize(), args)
end

"""
    customize(osrm_base; extra_args=String[])

Calls `osrm-customize` to finish MLD setup, keeping the artifact-provided binary
and flags centralized.
"""
function customize(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    cmd = customize_cmd(osrm_base; extra_args = extra_args)
    run_or_throw(cmd)
end
