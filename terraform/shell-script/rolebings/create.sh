#!/bin/bash
set -eo pipefail

RESOURCE_ID=$(echo "$RESOURCE_FILTER" | jq -er .id)

DIR_INFO=$(
  cat <<-END
{
  "a1": {
    "dir": "aaa"
  },
  "b2": {
    "dir": "bbb"
  },
  "c3": {
    "dir": "ccc"
  }
}
END
)

DIR=$(echo "${DIR_INFO}" | jq -er ."${RESOURCE_ID}".dir)
mkdir -p "${DIR}"

cat <<-END
{
    "dir": "${DIR}"
}
END
