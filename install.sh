#!/usr/bin/env bash
set -Eeuo pipefail

repository="https://github.com/nifunifunifura-stack/chromium-on-codespaces.git"
branch="main"

if ! command -v git >/dev/null 2>&1; then
  printf 'Git is required to download the Codespaces Chromium setup.\n' >&2
  exit 1
fi

workspace_root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || pwd)"
source_dir="$(mktemp -d)"
trap 'rm -rf "$source_dir"' EXIT

git clone --quiet --depth 1 --branch "$branch" "$repository" "$source_dir/repository"
cd "$workspace_root"
bash "$source_dir/repository/codespaces-chromium/setup.sh"
