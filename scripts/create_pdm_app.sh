#!/bin/bash
#
# create_pdm_app.sh

###
##
# |0| Setup

# errexit
set -e

# Set colorize variables
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
cyan="\033[0;36m"
white="\033[0;37m"
color_reset="\033[0m"

starter_name="pdm-env-starter"

###
##
# |1| Verify dependencies

# TODO: Either determine if rename is perl-rename or replace with generic method
if ! command -v rename &> /dev/null; then
  echo -e "Install$cyan rename$color_reset package to continue"
  exit 1
fi

###
##
# |2| Get user input

echo -e "${cyan}Creating from ${starter_name}...$color_reset"

# Project name
NAME="my-app"
if [[ -z "$1" ]]; then
  echo -ne "What is your project named? ${cyan}(my-app)${color_reset}: "
  read project_name
  if [[ ! -z "$project_name" ]]; then
    NAME="$project_name"
  fi
  if [[ "$project_name" =~ " " ]]; then
    echo "Error: Name cannot include whitespace"
    exit 1
  fi
else
  NAME="$1"
fi

# License
LICENSE="MIT"
echo -ne "License(SPDX name) ${cyan}(MIT)${color_reset}: "
read license
if [[ ! -z "$license" ]]; then
  LICENSE="$license"
fi

# Author name
AUTHOR_NAME=$(git config user.name)
echo -ne "Author name ${cyan}($AUTHOR_NAME)${color_reset}: "
read author_name
if [[ ! -z "$author_name" ]]; then
  AUTHOR_NAME="$author_name"
fi

# Author email
AUTHOR_EMAIL=$(git config user.email)
echo -ne "Author email ${cyan}($AUTHOR_EMAIL)${color_reset}: "
read author_email
if [[ ! -z "$author_email" ]]; then
  AUTHOR_EMAIL="$author_email"
fi

###
##
# Get required python version

# Helper to append to paths list
paths=()
add_to_list() {
  # Ignore paths that end in -config or are not executable or unique
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
options=("${paths[@]}")
counter=0
versions=()
for opt in "${options[@]}"; do
  versions+=( "$("$opt" -c "import sys; print('.'.join(map(str, sys.version_info[:2])))" 2>/dev/null)" )
done
echo "Please choose a Python interpreter:"
for index in "${!options[@]}"; do
  opt="${options[$index]}"
  version="${versions[$index]}"
  if [[ -n $version ]]; then
    echo -e "$counter) ${green}$opt${color_reset} ($version)"
    counter=$((counter + 1))
  fi
done

# Get user's choice
echo -ne "Enter the number of the Python interpreter you want to use ${cyan}(0)${color_reset}: "
read choice

# Check if the choice is valid
if [[ $choice -lt 0 || $choice -ge ${#options[@]} ]]; then
  echo "Invalid choice!"
  exit 1
fi

# Set variables and inform user
SELECTED_PYTHON_PATH=${options[$choice]}
SELECTED_PYTHON_VERSION=${versions[$choice]}
echo -e "${green}You are using PEP 582, no virtualenv is created.$color_reset"
echo -e "${green}For more info, please visit https://peps.python.org/pep-0582/$color_reset"

# Get required python version
echo -ne "Require Python version('*' to allow any) ${cyan}(>=${SELECTED_PYTHON_VERSION})${color_reset}: "
read REQ_PYTHON_VERSION

###
##
# |3| Create project from starter

# Clone starter into project directory
echo ""
mkdir "$NAME"
cd "$NAME"
if [[ -z "$OVERRIDE_STARTER_REPO" ]]; then
  git clone https://github.com/tw-studio/pdm-env-starter.git .
else
  git clone --branch "${OVERRIDE_STARTER_BRANCH:=main}" "$OVERRIDE_STARTER_REPO" .
fi
rm -rf .git
git init

# Prepare different formats of NAME and DATE
UNDERSCORED_NAME=${NAME//-/_} # database variables
PASCAL_CASE_NAME=$(perl -pe 's/(^|-|_)(\w)/\U$2/g' <<<"$NAME") # cdk
TODAYS_DATE="$(date +'%Y-%m-%d')"

# Reset key files
rm -f .gitignore
mv RENAME_TO.gitignore .gitignore
rm -f CHANGELOG.md
mv RENAME_TO_CHANGELOG.md CHANGELOG.md
perl -i -pe "s#YYYY\-MM\-DD#$TODAYS_DATE#g" CHANGELOG.md
rm -f THIRD_PARTY_NOTICES.md
mv RENAME_TO_THIRD_PARTY_NOTICES.md THIRD_PARTY_NOTICES.md
perl -i -pe "s#AUTHOR#$AUTHOR_NAME#g" THIRD_PARTY_NOTICES.md

# pyproject.toml
perl -i -pe "s#pdm\-env\-starter#$NAME#g" pyproject.toml
perl -i -pe "s#tw#$AUTHOR_NAME#g" pyproject.toml
perl -i -pe "s#\<\>#$AUTHOR_EMAIL#g" pyproject.toml
perl -i -pe "s#\>\=3\.11#$REQ_PYTHON_VERSION#g" pyproject.toml
perl -i -pe "s#UNLICENSED#$LICENSE#g" pyproject.toml

# pdm files
rm -f pdm.lock
rm -f .pdm-python
echo "$SELECTED_PYTHON_PATH" > .pdm-python

# env
mv env/RENAME_TO_development_secrets.py env/_development_secrets.py
