#!/bin/bash
set -eufo pipefail
IFS=$'\t\n'

# check variables
if [ "${GRAFANA_URL:-unset}" = "unset" ]; then
  echo "ERROR: Mising GRAFANA_URL variable"
  exit 2
fi

if [ "${GRAFANA_TOKEN:-unset}" = "unset" ]; then
  echo "ERROR: Mising GRAFANA_TOKEN variable"
  exit 2
fi

get(){
  path="$1"
  curl -# "${GRAFANA_URL}${path}" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${GRAFANA_TOKEN}"
}

# cleanup
rm -rf "data"
mkdir -p "data/dashboards"

# fetch dashboards
while read -r line; do
  IFS=$'\t' read -r title uri <<< "${line}"
  echo "Dashboard: ${title}"
  get "/api/dashboards/${uri}" > "data/dashboards/${title// /_}.json"
done < <(get "/api/search" | jq -r '.[] | "\(.title)\t\(.uri)"')

# fetch datasources
get "/api/datasources" > "data/datasources.json"
