#!/usr/bin/env bash
set -eux

nim compile --opt:speed --run --out:output/ src/$1.nim
