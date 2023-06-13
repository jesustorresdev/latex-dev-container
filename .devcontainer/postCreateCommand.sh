#!/bin/sh
set -e

mkdir ./build > /dev/null 2>&1 || true

if [ -r "./requirements.txt" ]; then
    cat ./requirements.txt | xargs --no-run-if-empty tlmgr install
    texhash
    luaotfload-tool -f -u -p -v
fi