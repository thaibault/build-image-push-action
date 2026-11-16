#!/usr/bin/env bash
# Prints each tag of the space separated "TAGS" environment variable once per
# line. "main" and "master" are printed as "latest". Without "TAGS" the name of
# the branch or tag the workflow runs for is printed.
set -euo pipefail

names=()
if [[ "${TAGS:-}" == '' ]]; then
    names=("$GITHUB_REF_NAME")
else
    read -r -d '' -a tags <<< "$TAGS" || true
    for name in "${tags[@]}"; do
        if [[ "$name" == main || "$name" == master ]]; then
            name=latest
        fi
        names+=("$name")
    done
fi

declare -A included_names=()
for name in "${names[@]}"; do
    if [[ "${included_names[$name]:-}" == '' ]]; then
        included_names[$name]=true
        echo "$name"
    fi
done
