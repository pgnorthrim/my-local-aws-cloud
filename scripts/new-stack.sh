#!/usr/bin/env bash
# Create a Terraform stack for local Moto from templates/project.
#   scripts/new-stack.sh <name>              -> stacks/<name>/ in this repo
#   scripts/new-stack.sh <name> <target-dir> -> <target-dir>/ (e.g. inside another project)
# Module sources are written as relative paths back to this repo's modules/.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
name=${1:?usage: new-stack.sh <name> [target-dir]}
target=${2:-$ROOT/stacks/$name}

[[ $name =~ ^[a-z0-9][a-z0-9-]{1,40}$ ]] || { echo "name: lowercase letters, digits, hyphens" >&2; exit 1; }
[ -e "$target" ] && { echo "$target already exists" >&2; exit 1; }

mkdir -p "$target"
target=$(cd "$target" && pwd)
modules=$(realpath --relative-to="$target" "$ROOT/modules")
case $modules in .*) ;; *) modules="./$modules" ;; esac

for f in provider.tf variables.tf main.tf; do
  sed -e "s|__STACK__|$name|g" -e "s|__MODULES__|$modules|g" "$ROOT/templates/project/$f" > "$target/$f"
done
cp "$ROOT/templates/project/gitignore" "$target/.gitignore"
echo "Created $target (modules: $modules)"
echo "Next: $ROOT/scripts/tf-apply.sh $target"
