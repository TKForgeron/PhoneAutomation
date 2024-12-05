#!/bin/bash

# Check battery status and exit if under 20%
battery_percentage=$(termux-battery-status | grep -oP '"percentage":\s*\K\d+')
battery_perc_int=$((battery_percentage))
if ((battery_perc_int < 20)); then
    echo "Battery level is too low for backup. Please charge your device."
    exit 1
fi

# Define source and destination folders
source_dir_backups="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Backups"
source_dir_media="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media"
source_dir_databases="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Databases"
source_dirs=(
    "$source_dir_backups"
    "$source_dir_media"
    "$source_dir_databases"
)
destination_zip_dir="/storage/emulated/0/Backups/WhatsApp"

# Create destination directory if it does not already exist
mkdir -p "$destination_zip_dir"

# Create a timestamp
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Maximum size for zip files (2 GB)
max_zip_size=$((2 * 1024 * 1024 * 1024))

# Loop through each source directory and create zip files
for dir in "${source_dirs[@]}"; do
    # Get the base name of the directory (e.g., Backups, Media, Databases)
    dir_name=$(basename "$dir")

    # Initialize variables for zipping
    current_zip_size=0
    zip_index=1
    zip_file_path="$destination_zip_dir/${dir_name}_backup_${timestamp}_part${zip_index}.zip"

    # Find all non-hidden files and directories
    while IFS= read -r file; do
        file_size=$(stat -c%s "$file")

        # Check if adding this file would exceed the max zip size
        if (( current_zip_size + file_size > max_zip_size )); then
            # Close the current zip file and start a new one
            zip_index=$((zip_index + 1))
            zip_file_path="$destination_zip_dir/${dir_name}_backup_${timestamp}_part${zip_index}.zip"
            current_zip_size=0
        fi

        # Add the file to the current zip
        zip -r "$zip_file_path" "$file" -q
        current_zip_size=$((current_zip_size + file_size))

    done < <(find "$dir" -mindepth 1 ! -path '*/.*')

    echo "Backup completed for $dir: $zip_file_path"
done