#!/bin/bash

# Function to recursively calculate and list directories within size limits
find_minimal_dirs() {
    local dir=$1       # Current directory
    local max_size=$2  # Maximum allowed size in bytes
    local dir_size=$(du -sb "$dir" | cut -f1) # Get size of the current directory

    if [ "$dir_size" -le "$max_size" ]; then
        echo "$dir"
    else
        local subdir
        for subdir in "$dir"/*; do
            if [ -d "$subdir" ]; then
                find_minimal_dirs "$subdir" "$max_size" # Recursive call for subdirectories
            fi
        done
    fi
}

# Example usage
root_dir="./test_directory"  # Replace with your target directory
max_bytes=5000000           # 5 MB limit, replace with your desired size limit
echo "Minimal list of directories:"
find_minimal_dirs "$root_dir" "$max_bytes"