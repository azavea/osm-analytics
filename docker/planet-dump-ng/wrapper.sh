#!/bin/sh
set -e

if [ -z "$1" ]; then
    planet-dump-ng --help
fi

planet-dump-ng --help

