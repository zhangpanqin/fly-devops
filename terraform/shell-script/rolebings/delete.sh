#!/bin/bash
set -eo pipefail

IN=$(cat)
DIR=$(echo "${IN}" | jq -er .dir)
echo "RESOURCE_FILTER_${RESOURCE_FILTER}" >>"delete.txt"
echo "MY_NAME_${MY_NAME}" >>"delete.txt"
rm -fr "${DIR}"
