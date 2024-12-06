#!/bin/bash

# Define the threshold in MB
threshold=20  # 20 MB

# Create a main directory
main_dir="data"
mkdir -p "$main_dir"

# Function to create subdirectories with test files
create_subdir() {
    local subdir_name="$1"
    local size_mb="$2"
    local exceeds_threshold="$3"
    
    subdir="$main_dir/${subdir_name}_${size_mb}MB_${exceeds_threshold}"
    mkdir -p "$subdir"
    
    # Create test files to fill the subdirectory to the specified size
    file_size=$((size_mb / 10))  # Divide the total size into 10 files
    for j in {1..10}; do
        dd if=/dev/zero of="$subdir/test_file_$j" bs=1M count="$file_size"  # Create files of specified size
    done
}

# Create subdirectories with varying sizes
create_subdir "subdir" 15 "under_threshold"  # 15 MB, under threshold
create_subdir "subdir" 25 "over_threshold"   # 25 MB, over threshold
create_subdir "subdir" 20 "under_threshold"  # 10 MB, under threshold
create_subdir "subdir" 30 "over_threshold"   # 30 MB, over threshold
create_subdir "subdir" 5 "under_threshold"   # 5 MB, under threshold

echo "Test directory structure created in '$main_dir'"
