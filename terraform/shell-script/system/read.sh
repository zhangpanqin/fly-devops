#!/bin/bash
set -eo pipefail

SYSTEM_INFO=$(
  cat <<-END
{
  "a": {
    "id": "a1"
  },
  "b": {
    "id": "b2"
  },
  "c": {
    "id": "c3"
  }
}
END
)
SYSTEM_ID=$(echo "${SYSTEM_INFO}" | jq -er ."${SYSTEM_NAME}".id)

cat <<-END
{
    "system_id": "${SYSTEM_ID}"
}
END
