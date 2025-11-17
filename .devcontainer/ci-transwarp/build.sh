#!/bin/bash

common_build_args="
  --network=host
  --build-arg postgres_uid=199
  --build-arg postgres_gid=199
"

function image_suffix {
  commit=$(git rev-parse --short HEAD)
  current_date=$(date +%Y%m%d)

  echo "${current_date}_${commit}"

  unset commit
  unset current_date
}

function build_runtime {
  tag=$(image_suffix)

  build_args="
    ${common_build_args}
    --build-arg OUTPUT_DIR=output
  "

  docker build \
    ${build_args} \
    -t pg_runtime:${tag} \
    -f Dockerfile \
    .

  unset tag
  unset build_args
}
