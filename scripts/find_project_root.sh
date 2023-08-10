#!/bin/bash
#
# find_project_root.sh
# Searches up the directory chain for pyproject.toml and prints it if found

initial_dir=$(pwd)

while [[ "$current_dir" != "/" ]]; do

    current_dir=$(pwd)

    if [[ -f "$current_dir/pyproject.toml" ]]; then
        echo "$current_dir"
        exit 0
    fi
    
    cd ..
done

# If we've reached here, we didn't find pyproject.toml
cd "$initial_dir"
exit 1
