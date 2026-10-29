#!/usr/bin/env bash
# Apply a Moto stack: init if needed, apply, and apply again if anything is left over.
# Moto ignores tags sent with CreateBucket, so new buckets are tagged on the second pass.
#   scripts/tf-apply.sh <stack-dir> [extra terraform args]
set -euo pipefail
dir=${1:?usage: tf-apply.sh <stack-dir> [terraform args]}; shift
cd "$dir"

ep=$(sed -n 's/.*default *= *"\(http:\/\/localhost:[0-9]*\)".*/\1/p' variables.tf | head -1)
curl -sf -o /dev/null "${ep:-http://localhost:4566}/moto-api/" \
  || { echo "Moto is not answering on ${ep:-http://localhost:4566}. Run: docker compose up -d" >&2; exit 1; }

export TF_PLUGIN_CACHE_DIR=${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}
[ -d .terraform ] || terraform init -input=false >/dev/null

terraform apply -input=false -auto-approve -no-color "$@" | grep -E "Apply complete|Error" || true
set +e
terraform plan -input=false -no-color -detailed-exitcode "$@" >/dev/null 2>&1
rc=$?
set -e
if [ "$rc" -eq 2 ]; then
  terraform apply -input=false -auto-approve -no-color "$@" | grep -E "Apply complete|Error" || true
elif [ "$rc" -ne 0 ]; then
  echo "terraform plan failed (run it by hand to see why)" >&2; exit 1
fi
