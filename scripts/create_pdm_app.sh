#!/bin/bash
#
# create_pdm_app.sh

# errexit
set -e

# Set colorize variables
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
cyan="\033[0;36m"
white="\033[0;37m"
color_reset="\033[0m"

# Verify dependencies
# TODO: Either determine if rename is perl-rename or replace with generic method
if ! command -v rename &> /dev/null; then
  echo -e "Install$cyan rename$color_reset package to continue"
  exit 1
fi

# Get project name
NAME="my-app"
if [[ -z "$1" ]]; then
  echo -ne "$cyan?$color_reset What is your project named? ${cyan}(my-app)${color_reset}: "
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

# Get license
LICENSE="MIT"
echo -ne "License(SPDX name) ${cyan}(MIT)${color_reset}: "
read license
if [[ ! -z "$license" ]]; then
  LICENSE="$license"
fi

# Get author name
AUTHOR_NAME=$(git config user.name)
echo -ne "Author name ${cyan}($AUTHOR_NAME)${color_reset}: "
read author_name
if [[ ! -z "$author_name" ]]; then
  AUTHOR_NAME="$author_name"
fi

# Get author email
AUTHOR_EMAIL=$(git config user.email)
echo -ne "Author email ${cyan}($AUTHOR_EMAIL)${color_reset}: "
read author_email
if [[ ! -z "$author_email" ]]; then
  AUTHOR_EMAIL="$author_email"
fi

# Get required python version
REQ_PYTHON_VERSION=
echo -ne "Python requires('*' to allow any) ${cyan}(>=3.11)${color_reset}: "

# Creating a pyproject.toml for PDM...
# Please enter the Python interpreter to use
# 0. /usr/local/bin/python (3.11)
# 1. /usr/local/bin/python3.11 (3.11)
# 2. /usr/local/bin/python3.10 (3.10)
# 3. /usr/local/bin/python3.9 (3.9)
# 4. /usr/local/bin/python3.8 (3.8)
# 5. /usr/bin/python3 (3.8)
# 6. /usr/local/Cellar/python@3.11/3.11.4_1/Frameworks/Python.framework/Versions/3.11/bin/python3.11 (3.11)
# Please select (0):
# Would you like to create a virtualenv with /usr/local/bin/python3.11? [y/n] (y):
# You are using the PEP 582 mode, no virtualenv is created.
# For more info, please visit https://peps.python.org/pep-0582/
# Is the project a library that is installable?
# If yes, we will need to ask a few more questions to include the project name and build backend [y/n] (n):

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
mv env/RENAME_TO_development_secrets.py env/_development_secrets.py
