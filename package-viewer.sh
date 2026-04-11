#!/usr/bin/env bash
set -euo pipefail

echo "package-viewer.sh is now a compatibility wrapper."
echo "Delegating to canonical packaging script: ./package.sh"
./package.sh
