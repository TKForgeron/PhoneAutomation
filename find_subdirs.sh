#!/bin/bash

# Function to find subdirectories with a maximum size of 2GB
find_subdirs() {
    local dir=$1
    local max_size=$2  # Max size in bytes
    local allowed_subdirs=()
    local disallowed_subdirs=()

    # Find all immediate subdirectories and files
    for subdir in "$dir"/*; do
        # check if its a directory
        if [ -d "$subdir" ]; then 
            dir_size=$(du -sb "$subdir" | cut -f1)
            # printf "Checking directory: $subdir, Size: $dir_size bytes\n"
            if (( dir_size < max_size )); then
                allowed_subdirs+=("$subdir")
            else
                disallowed_subdirs+=("$subdir")
                # Recursively check disallowed subdirectories
                find_subdirs "$subdir" "$max_size"
            fi
        # check if its a file
        elif [ -f "$subdir" ]; then
            file_size=$(stat -c%s "$subdir")
            # printf "Checking file: $subdir, Size: $file_size bytes\n"
            if (( file_size < max_size )); then
                allowed_subdirs+=("$subdir")
            else
                disallowed_subdirs+=("$subdir")
            fi
        fi
    done

    echo "${allowed_subdirs[@]}"

}

create_grouped_zip_archives() {
    local max_size=$1  # Max size in bytes
    shift
    local paths=("$@")  # Remaining arguments are the paths

    local current_zip_size=0
    local zip_index=1
    local current_zip_files=()
    
    for path in "${paths[@]}"; do
        # Get the size of the current path
        if [ -d "$path" ]; then
            path_size=$(du -sb "$path" | cut -f1)
        elif [ -f "$path" ]; then
            path_size=$(stat -c%s "$path")
        else
            echo "Skipping invalid path: $path"
            continue
        fi

        # Check if adding this path would exceed the max size
        if (( current_zip_size + path_size < max_size )); then
            current_zip_files+=("$path")
            current_zip_size=$((current_zip_size + path_size))
        else
            # Create the zip archive for the current set of files
            zip_file="archive_$zip_index.zip"
            zip -r "$zip_file" "${current_zip_files[@]}"
            echo "Created zip archive: $zip_file with size: $current_zip_size bytes"

            # Reset for the next zip archive
            current_zip_files=("$path")
            current_zip_size=$path_size
            zip_index=$((zip_index + 1))
        fi
    done

    # Create the last zip archive if there are remaining files
    if [ ${#current_zip_files[@]} -gt 0 ]; then
        zip_file="archive_$zip_index.zip"
        zip -r "$zip_file" "${current_zip_files[@]}"
        echo "Created zip archive: $zip_file with size: $current_zip_size bytes"
    fi
}

# Example usage
# find_subdirs "/path/to/directory" 20971520  # 20MB in bytes


# Example usage
# echo -n "Please enter a directory name: "
# read source_dir
source_dir="data"
max_dir_size=$((2 * 1024 * 1024 * 10))
subdirs=$(find_subdirs "$source_dir" $max_dir_size)
# create_grouped_zip_archives "$max_dir_size" "${subdirs[@]}"
