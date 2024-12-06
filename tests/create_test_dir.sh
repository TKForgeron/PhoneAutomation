#!/bin/bash

# Define the threshold in MB
threshold=20  # 20 MB

# Create a main directory
main_dir="data/input"
mkdir -p "$main_dir"

# Function to create subdirectories with test files
create_subdir() {
    local subdir_name="$1"
    local size_mb="$2"
    local exceeds_threshold="$3"
    
    subdir="$main_dir/${subdir_name}_${size_mb}MB_${exceeds_threshold}"
    mkdir -p "$subdir"
    
    # Create test files to fill the subdirectory to the specified size
    file_size=$((size_mb / 100))  # Divide the total size into 10 files
    for j in {1..100}; do
        dd if=/dev/zero of="$subdir/test_file_$j" bs=1M count="$file_size"  # Create files of specified size
    done
}

# Create subdirectories with varying sizes
create_subdir "subdir" 2000 "around"  # 10 MB, under threshold
create_subdir "subdir" 2200 "over"   # 30 MB, over threshold
create_subdir "subdir" 50 "under"   # 5 MB, under threshold

echo "Test directory structure created in '$main_dir'"
