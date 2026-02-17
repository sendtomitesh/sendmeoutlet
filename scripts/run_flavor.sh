#!/bin/bash
# Run sendme_outlet with a specific flavor
# Usage: ./scripts/run_flavor.sh <flavor> [extra flutter args...]
# Example: ./scripts/run_flavor.sh sendme
# Example: ./scripts/run_flavor.sh sendme6 -d emulator-5554

set -e

FLAVOR=${1:-sendme}

echo "Running flavor: $FLAVOR"
flutter run --flavor "$FLAVOR" "${@:2}"
