#!/bin/bash
#
# run_with_env.sh

# Check number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./run_with_env.sh [environment] [script_path]"
    exit 1
fi

# Get PDM's python path
PDM_PYTHON=$(pdm info --python 2>&1)
if [ $? -ne 0 ]; then
    echo "Error: $PDM_PYTHON"
    exit 1
fi

# Search up directory chain for pyproject.toml
initial_dir=$(pwd)
PDM_ROOT=""
while [[ "$current_dir" != "/" ]]; do
    current_dir=$(pwd)
    if [[ -f "$current_dir/pyproject.toml" ]]; then
        PDM_ROOT="$current_dir"
        break
    fi
    cd ..
done

if [ -z "$PDM_ROOT" ]; then
    cd "$initial_dir"
    echo "Error: pyproject.toml not found in any parent directory"
    exit 1
fi

# Change to the project root
cd "$PDM_ROOT"
export PDM_ROOT

# Set PDM_ENV based on the first argument
export PDM_ENV=$1

# Source the environment variables
eval $($PDM_PYTHON -m scripts.load_env)

# Execute the provided script
$PDM_PYTHON $2

# Change back to the initial directory
cd "$initial_dir"
