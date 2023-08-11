#!/bin/bash

# Array to hold our discovered Python paths
paths=()

# Function to append to our list if the path is unique and executable
add_to_list() {
  # Ignore paths that end in -config or are not executable
  if [[ ! " ${paths[@]} " =~ " $1 " && -x $1 && ! "$1" =~ "-config" ]]; then
    paths+=("$1")
  fi
}

# 1. Check in common directories
for dir in /usr/local/bin /usr/bin; do
  for py in "$dir"/python*; do
    add_to_list "$py"
  done
done

# 2. System defaults
add_to_list "$(which python 2>/dev/null)"
add_to_list "$(which python3 2>/dev/null)"

# 3. Pyenv check
if [ -d "$PYENV_ROOT" ]; then
  if [ -f "$PYENV_ROOT/shims/python3" ]; then
    add_to_list "$PYENV_ROOT/shims/python3"
  elif [ -f "$PYENV_ROOT/shims/python" ]; then
    add_to_list "$PYENV_ROOT/shims/python"
  fi
fi

# Display python interpreters to the user
echo "Please choose a Python interpreter:"
options=("${paths[@]}")
counter=0
for opt in "${options[@]}"; do
  version=$("$opt" -c "import sys; print('.'.join(map(str, sys.version_info[:2])))" 2>/dev/null)
  if [[ $? -eq 0 ]]; then
    echo "$counter) $opt (Python $version)"
    counter=$((counter + 1))
  fi
done

# Get user's choice
read -p "Enter the number of the Python interpreter you want to use: " choice

# Check if the choice is valid
if [[ $choice -lt 0 || $choice -ge ${#options[@]} ]]; then
  echo "Invalid choice!"
  exit 1
fi

selected_python=${options[$choice]}
echo "You selected: $selected_python"

