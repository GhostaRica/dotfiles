#!/bin/bash

# Check if a directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Set the target directory
TARGET_DIR="$1"

# Function to find and delete files with non-printable characters in their names
delete_bad_files() {
    local dir="$1"
    echo "Processing directory for files: $dir"
    # Find files with non-printable characters in their names and delete them using their inode numbers
    find "$dir" -type f | while read -r file; do
        if [[ $(echo "$file" | LC_ALL=C grep -P '[^\x00-\x7F]') ]]; then
            inode=$(ls -li "$file" | awk '{print $1}')
            echo "Found file with non-printable characters: $file (inode: $inode)"
            find "$dir" -inum "$inode" -exec echo "Deleting file: {}" \; -exec rm -f {} \;
        fi
    done
}

# Function to find and delete directories with non-printable characters in their names
delete_bad_dirs() {
    local dir="$1"
    echo "Processing directory for subdirectories: $dir"
    # Find directories with non-printable characters in their names and delete them
    find "$dir" -type d | while read -r subdir; do
        if [[ $(echo "$subdir" | LC_ALL=C grep -P '[^\x00-\x7F]') ]]; then
            inode=$(ls -ldi "$subdir" | awk '{print $1}')
            echo "Found directory with non-printable characters: $subdir (inode: $inode)"
            find "$dir" -inum "$inode" -exec echo "Deleting directory: {}" \; -exec rm -rf {} \;
        fi
    done
}

# Export the functions so they can be used by find -exec
export -f delete_bad_files
export -f delete_bad_dirs

# Traverse the target directory and process each subdirectory
find "$TARGET_DIR" -type d -exec bash -c 'delete_bad_files "$0"' {} \;

# Traverse the target directory again to process directories with non-printable characters
find "$TARGET_DIR" -type d -exec bash -c 'delete_bad_dirs "$0"' {} \;

echo "Completed deleting files and directories with non-printable characters in their names."
