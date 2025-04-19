#!/usr/bin/env sh

set -e

cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build
# TODO: add ctest
