function partition_cmd(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_partition(), args)
end

"""
    partition(osrm_base; extra_args=String[])

Executes `osrm-partition` so MLD preparations stay in Julia scripts rather than
shell pipelines.
"""
function partition(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    cmd = partition_cmd(osrm_base; extra_args = extra_args)
    run_or_throw(cmd)
end
