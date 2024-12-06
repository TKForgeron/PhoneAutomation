#!/bin/bash

# Function to find subdirectories with a maximum size of 2GB
find_subdirs1() {
    local dir="$1"
    local max_size=$2  # Max size in bytes
    local allowed_subdirs=()
    local disallowed_subdirs=()
    
    # Find all immediate subdirectories and files
    for subdir in "$dir"/*; do
        # escape any whitespace in the path
        subdir=$(echo "'$subdir'")
        # check if its a directory
        if [ -d "$subdir" ]; then
            dir_size=$(du -sb "$subdir" | cut -f1)
            echo 'here'
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
            echo 'here'
            file_size=$(stat -c%s "$subdir")
            # printf "Checking file: $subdir, Size: $file_size bytes\n"
            if (( file_size < max_size )); then
                allowed_subdirs+=("$subdir")
            else
                disallowed_subdirs+=("$subdir")
            fi
        fi
        echo 'here'

    done

    echo "${allowed_subdirs[@]}"
}

find_subdirs() {
    local dir="$1"
    local max_size=$2  # Max size in bytes
    local allowed_subdirs=()
    # local disallowed_subdirs=()

    # Use find to get all subdirectories and their sizes
    while IFS= read -r -d '' subdir; do
        if [ -d "$subdir" ]; then
            dir_size=$(du -sb "$subdir" | cut -f1)
            if (( dir_size < max_size )); then
                allowed_subdirs+=("$subdir'split_here'")
            else
                # disallowed_subdirs+=("$subdir")
                # Recursively check disallowed subdirectories
                find_subdirs "$subdir" "$max_size"
            fi
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0)

    # Use find to get all files and their sizes
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            file_size=$(stat -c%s "$file")
            if (( file_size < max_size )); then
                allowed_subdirs+=("$file,")
            # else
            #     disallowed_subdirs+=("$file")
            fi
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -print0)

    echo "${allowed_subdirs[@]}"
}

create_grouped_zip_archives() {
    local max_size=$(($1))  # Max size in bytes
    local destination_zip_base_dir_str="$2"
    shift
    shift
    local paths=("$@")  # Remaining arguments are the paths

    local current_zip_size=0
    local zip_index=1
    local current_zip_files=()

    for path in "${paths[@]}"; do
        # Get the size of the current path
        echo "$path"
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
            zip_file="${destination_zip_base_dir_str}_part_${zip_index}.zip"
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
        zip_file="${destination_zip_base_dir_str}_part_${zip_index}.zip"
        zip -r "$zip_file" "${current_zip_files[@]}"
        echo "Created zip archive: $zip_file with size: $current_zip_size bytes"
    fi
}

# Executing the pipeline...
# Check battery status and exit if under 20%
# battery_percentage=$(termux-battery-status | grep -oP '"percentage":\s*\K\d+')
# battery_perc_int=$((battery_percentage))
# if ((battery_perc_int < 20)); then
#     echo "Battery level is too low for backup. Please charge your device."
#     exit 1
# fi

# source_dir_backups="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Backups"
# source_dir_media="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media"
# source_dir_databases="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Databases"
source_dir_backups="data/input/subdir_2200MB_over"
source_dir_databases="data/input/subdir_2000MB_around"
source_dir_media="data/input/Media"

source_dirs=(
    "$source_dir_backups"
    # "$source_dir_media"
    # "$source_dir_databases"
)
# destination_zip_dir="/storage/emulated/0/Backups/WhatsApp"
destination_zip_dir="data/output"
# Create dir if it does not already exist
mkdir -p "$destination_zip_dir"
max_zip_input_size=$((2 * 1024 * 1024 * 1020)) # 2GB in bytes
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

for source_dir in "${source_dirs[@]}"; do
    # Get the base name of the directory (e.g., Backups, Media, Databases)
    bname=$(basename "$source_dir")
    # Set a consistent name base for the zips
    destination_zip_base_dir_str="${destination_zip_dir}/${bname}_backup_${timestamp}"
    # Find subdirectories in the given $source_dir, such that the whole directory is split into parts not greater than $max_zip_input_size
    subdirs=$(find_subdirs "$source_dir" $max_zip_input_size)
    # parse the string into an array of paths that allow for whitespace
    function mfcb { local val="$4"; "$1"; eval "$2[$3]=\$val;"; };
    function val_ltrim { if [[ "$val" =~ ^[[:space:]]+ ]]; then val="${val:${#BASH_REMATCH[0]}}"; fi; };
    function val_rtrim { if [[ "$val" =~ [[:space:]]+$ ]]; then val="${val:0:${#val}-${#BASH_REMATCH[0]}}"; fi; };
    function val_trim { val_ltrim; val_rtrim; };
    readarray -c1 -C 'mfcb val_trim parsed_paths' -td, <<<"$subdirs,"; unset 'a[-1]'; declare parsed_paths;
    escaped_parsed_paths=()
    # Iterate over the original array
    for path in "${parsed_paths[@]}"; do
        # Replace spaces with backslash followed by a space
        modified_value="'$path'"
        # modified_value="${path// /\\ }"
        # Append the modified value to the new array
        escaped_parsed_paths+=("$modified_value")
    done
    
    # Archive (sub) directories into parts of max 2GB
    create_grouped_zip_archives $max_zip_input_size "$destination_zip_base_dir_str" "${escaped_parsed_paths[@]}"
done
