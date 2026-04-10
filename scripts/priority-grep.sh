#!/bin/sh
# Grep priority directories first, then the rest of the repo.
# Usage: priority-grep.sh <query> [extra rg args...]
query="$1"
shift
rg --line-number --column --color=always "$query" "$@" model-serving/serving-engine wheelhouse/deptrees
rg --line-number --column --color=always "$query" "$@" --glob '!model-serving/serving-engine/**' --glob '!wheelhouse/deptrees/**'
