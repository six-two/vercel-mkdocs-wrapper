#!/usr/bin/bash
# Usage: [git-repo-url] [website-title]
# Those values can also be set via environment variables:
# $DOCS_REPO and $DOCS_NAME

# Change into the script's directory
# This is really important, since this script modifies (and deletes) files by relative paths
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"

# If this script is executed locally, the folders created by the last run should be deleted.
# Thus local and remote builds will (hopefully) not have different results
rm -rf docs public mkdocs.yml

# Determine the repos name:
NAME=${2:-$DOCS_NAME}
NAME=${NAME:-My Documents}
echo "Using website name: $NAME"

# Create the mkdocs.yml by replacing the name placeholder with the user supplied value
sed "s/<NAME>/$NAME/" mkdocs-template.yml > mkdocs.yml

# Determine which repo the git documents should be obtained from
# Preference order: Command line argument, environment variable, my hardcoded demo page URL
REPO=${DOCS_REPO:-https://github.com/six-two/notes-demo-page}
REPO=${1:-$REPO}
# Output for debugging purposes
echo "Using docs repo: ${REPO}"

# Install the static site generator and the theme
pip install mkdocs mkdocs-material

# Download the document repo to the docs folder
git clone "${REPO}" docs

# Delete the README.md file, since it often contains unnecessary stuff, such as installation instructions.
# If you want an index page, create a file called 'index.md' instead.
rm docs/README.md
# if no index.md file exists, create an empty page
if [ ! -f docs/index.md ]; then
  echo "# $NAME" > docs/index.md
fi

# Build the site. The result will be written in the ./public directory
mkdocs build -d public