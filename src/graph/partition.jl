function partition_cmd(
        osrm_base_path::AbstractString;
        extra_args::Vector{String} = String[],
    )
    # osrm_base_path is expected to be the full path to the `.osrm` file
    args = String[osrm_base_path]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_partition(), args)
end

"""
    partition(osrm_base_path; extra_args=String[])

Executes `osrm-partition` on an existing `.osrm` file so MLD preparations stay
in Julia scripts rather than shell pipelines.
"""
function partition(
        osrm_base_path::AbstractString;
        extra_args::Vector{String} = String[],
    )
    cmd = partition_cmd(osrm_base_path; extra_args = extra_args)
    run_or_throw(cmd)
end
