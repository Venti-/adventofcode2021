#!/usr/bin/env bash
set -eux

nim compile --run --out:output/ src/$1.nim
