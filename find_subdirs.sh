#!/bin/bash

# Function to find subdirectories with a maximum size of 2GB
find_subdirs() {
    local dir=$1
    local max_size=$2  # Max size in bytes
    local allowed_subdirs=()
    local disallowed_subdirs=()

    # Find all immediate subdirectories and files
    for subdir in "$dir"/*; do
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

# Example usage
# find_subdirs "/path/to/directory" 20971520  # 20MB in bytes


# Example usage
# echo -n "Please enter a directory name: "
# read source_dir
source_dir="data"
max_dir_size=$((2 * 1024 * 1024 * 10))
subdirs=$(find_subdirs "$source_dir" $max_dir_size)

# Print the found subdirectories
for subdir in $subdirs; do
        echo "$subdir"
done