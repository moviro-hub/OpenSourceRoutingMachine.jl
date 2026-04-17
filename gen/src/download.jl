"""
    download_flatbuffers(version; base_url, subdir, files, output_dir) -> Bool

Download FlatBuffer schema files (`.fbs`) from the OSRM backend GitHub repository
for a specific version tag. Returns `true` if all downloads succeeded.

# Arguments
- `version::String`: OSRM version tag (e.g. `"v26.4.0"`)
- `base_url::String`: Base URL for the raw GitHub content
- `subdir::String`: Subdirectory path within the repository
- `files::Vector{String}`: List of `.fbs` filenames to download
- `output_dir::String`: Local directory to write downloaded files to
"""
function download_flatbuffers(
    version::String;
    base_url::String,
    subdir::String,
    files::Vector{String},
    output_dir::String,
)::Bool
    mkpath(output_dir)

    failed_files = String[]
    for file in files
        url = "$base_url/$version/$subdir/$file"
        output_path = joinpath(output_dir, file)
        try
            println("Downloading $file...")
            Downloads.download(url, output_path)
            println("  [OK] $file")
        catch e
            println("  [FAIL] $file: $e")
            push!(failed_files, file)
        end
    end

    println()
    if isempty(failed_files)
        println("Successfully downloaded all $(length(files)) FlatBuffer files")
        return true
    else
        println("Failed to download $(length(failed_files)) file(s):")
        for file in failed_files
            println("  - $file")
        end
        return false
    end
end
