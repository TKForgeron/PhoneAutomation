# #!/bin/bash

# # Function to find subdirectories within size limits
# find_subdirs() {
#     local dir="$1"
#     local max_size=$2  # Max size in bytes
#     local allowed_subdirs=()
#     local disallowed_subdirs=()

#     # Use find to get all subdirectories and their sizes
#     while IFS= read -r -d '' subdir; do
#         if [ -d "$subdir" ]; then
#             dir_size=$(du -sb "$subdir" | cut -f1)
#             if (( dir_size < max_size )); then
#                 allowed_subdirs+=("$subdir")
#             else
#                 disallowed_subdirs+=("$subdir")
#                 # Recursively check disallowed subdirectories
#                 find_subdirs "$subdir" "$max_size"
#             fi
#         fi
#     done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0)

#     # Use find to get all files and their sizes
#     while IFS= read -r -d '' file; do
#         if [ -f "$file" ]; then
#             file_size=$(stat -c%s "$file")
#             if (( file_size < max_size )); then
#                 allowed_subdirs+=("$file")
#             else
#                 disallowed_subdirs+=("$file")
#             fi
#         fi
#     done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -print0)

#     echo "${allowed_subdirs[@]}"
# }

# find_subdirs1() {
#     local dir="$1"
#     local max_size=$2  # Max size in bytes
#     local allowed_subdirs=()
#     local disallowed_subdirs=()

#     # Find all immediate subdirectories and files
#     for subdir in "$dir"/*; do
#         # check if its a directory
#         if [ -d "$subdir" ]; then
#             dir_size=$(du -sb "$subdir" | cut -f1)
#             # printf "Checking directory: $subdir, Size: $dir_size bytes\n"
#             if (( dir_size < max_size )); then
#                 allowed_subdirs+=("$subdir")
#             else
#                 disallowed_subdirs+=("$subdir")
#                 # Recursively check disallowed subdirectories
#                 find_subdirs "$subdir" "$max_size"
#             fi
#         # check if its a file
#         elif [ -f "$subdir" ]; then
#             file_size=$(stat -c%s "$subdir")
#             # printf "Checking file: $subdir, Size: $file_size bytes\n"
#             if (( file_size < max_size )); then
#                 allowed_subdirs+=("$subdir")
#             else
#                 disallowed_subdirs+=("$subdir")
#             fi
#         fi
#     done

#     echo "${allowed_subdirs[@]}"
# }

# # Example usage
# root_dir="data"  # Replace with your target directory
# max_bytes=$((2 * 1024 * 1024 * 10)) # 2GB in bytes


# echo "Timing the find_subdirs function..."
# start_time=$(date +%s%N)
# subdirs=$(find_subdirs "$root_dir" "$max_bytes")
# end_time=$(date +%s%N)
# elapsed_time=$(( (end_time - start_time) / 1000000 ))  # Convert nanoseconds to milliseconds
# # echo $subdirs
# printf "Time taken: ${elapsed_time} ms \n" # 42901 ms
# printf "================== \n"

# echo "Timing the find_subdirs1 function..."
# start_time=$(date +%s%N)
# subdirs1=$(find_subdirs1 "$root_dir" "$max_bytes")
# end_time=$(date +%s%N)
# elapsed_time=$(( (end_time - start_time) / 1000000 ))  # Convert nanoseconds to milliseconds
# # echo $subdirs1
# printf "Time taken: ${elapsed_time} ms \n" # 37175 ms
# printf "================== \n"

# # conclusion: the original code is faster (find_subdirs1)

dir="data/input/subdir_2200MB_over"

while IFS= read -r -d '' subdir; do
    # Do something with subdir
    # subdir=$(echo "'$subdir'")
    echo $subdir
done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0)