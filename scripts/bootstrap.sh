#!/usr/bin/env bash
# Build the core local stack in Moto (buckets warehouse/bronze/silver/gold, stream "events").
# Safe to re-run; rerun after restarting Moto (it keeps state in memory).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
"$ROOT/scripts/tf-apply.sh" "$ROOT/stacks/core"
cd "$ROOT/stacks/core" && terraform output
