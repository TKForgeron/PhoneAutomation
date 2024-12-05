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

# Loop through each source directory and create a separate zip file for each
for dir in "${source_dirs[@]}"; do
    # Get the base name of the directory (e.g., Backups, Media, Databases)
    dir_name=$(basename "$dir")

    # Define the zip file path for this directory
    zip_file_path="$destination_zip_dir/${dir_name}_backup_$timestamp.zip"

    # Find all non-hidden files and directories and add them to the zip file
    find "$dir" -mindepth 1 ! -path '*/.*' -print | zip -r "$zip_file_path" -@

    echo "Backup completed for $dir: $zip_file_path"
done

