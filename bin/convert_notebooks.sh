#!/bin/sh
#
# Copyright 2023 DeepMind Technologies Limited.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Converts notebooks to .py files for testing.

readonly SCRIPT_DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
readonly EXAMPLES_DIR="${SCRIPT_DIR}"/../examples
readonly OUTPUT_DIR="$1"
readonly TEMP_DIR="$(mktemp -d)"


function find_notebooks() {
  find "${EXAMPLES_DIR}" -type f -iname '*.ipynb'
}


function collect_notebooks() {
  for file in $(find_notebooks); do
    echo "Copying ${file} to ${TEMP_DIR}"
    cp "${file}" "${TEMP_DIR}"
  done
}


function remove_cell_magic() {
  for file in "${TEMP_DIR}"/*; do
    echo "Removing cell magic from ${file}"
    sed -i "/^\s*\"%%/d" "${file}"
  done
}


function convert_notebooks() {
  jupyter nbconvert --to=python --output-dir="${OUTPUT_DIR}" \
      --RegexRemovePreprocessor.patterns='(%|!)pip' \
      "${TEMP_DIR}"/*
}


function main() {
  collect_notebooks \
  && remove_cell_magic \
  && convert_notebooks \
  && ls "${OUTPUT_DIR}"
}


main >&2
