#!/bin/bash

# Function to calculate the size of a directory in bytes
get_dir_size() {
    du -sb "$1" | cut -f1
}

# Recursive function to find minimal subdirectory groups
find_minimal_subdirs() {
    local dir="$1"       # Current directory to process
    local threshold="$2" # Size threshold in bytes
    local current_group_size=0

    echo "Processing directory: $dir"

    # Loop through items in the directory
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            # Get the size of the subdirectory
            local dir_size=$(get_dir_size "$item")
            
            if [ "$((current_group_size + dir_size))" -gt "$threshold" ]; then
                # If adding this directory exceeds the threshold, start a new group
                echo "=== New Group ==="
                echo "Directory: $item"
                current_group_size=0
            else
                # Otherwise, add it to the current group
                echo "Adding $item ($dir_size bytes)"
                current_group_size=$((current_group_size + dir_size))
            fi

            # Recurse into the subdirectory
            find_minimal_subdirs "$item" "$threshold"
        fi
    done
}

# Usage: Provide the directory path and threshold size
root_dir=$1
threshold=$2

if [ -z "$root_dir" ] || [ -z "$threshold" ]; then
    echo "Usage: $0 <root_directory> <size_threshold_in_bytes>"
    exit 1
fi

# Start the recursive function
find_minimal_subdirs "$root_dir" "$threshold"