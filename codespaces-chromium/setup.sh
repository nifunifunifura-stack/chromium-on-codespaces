#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ! -f .devcontainer/devcontainer.json ]]; then
  mkdir -p .devcontainer
  cat > .devcontainer/devcontainer.json <<'JSON'
{
  "name": "Codespaces Chromium Browser",
  "image": "mcr.microsoft.com/devcontainers/universal:2"
}
JSON
fi

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install_dir="$PWD/.codespaces-chromium"
config_dir="$install_dir"
workspace_files_dir="$PWD/browser-files"
browser_data_dir="$PWD/browser-data"

mkdir -p "$install_dir" "$workspace_files_dir" "$browser_data_dir"
touch "$PWD/.gitignore"
for entry in '/browser-data/' '/.codespaces-chromium/'; do
  if ! grep -qxF "$entry" "$PWD/.gitignore"; then
    printf '\n%s\n' "$entry" >> "$PWD/.gitignore"
  fi
done
install -m 644 "$source_dir/docker-compose.yml" "$install_dir/docker-compose.yml"
install -m 755 "$source_dir/webopen" "$install_dir/webopen"
install -m 755 "$source_dir/web" "$install_dir/web"

if [[ ! -f "$config_dir/.env" ]]; then
  umask 077
  printf 'BROWSER_USER=1234\nBROWSER_PASSWORD=1234\n' > "$config_dir/.env"
fi
chmod 600 "$config_dir/.env"

python3 "$source_dir/patch_devcontainer.py" \
  "$PWD/.devcontainer/devcontainer.json" \
  "$config_dir/.env" \
  "$workspace_files_dir" \
  "$browser_data_dir"
sudo install -m 755 "$install_dir/web" "$install_dir/webopen" /usr/local/bin/

printf 'Setup files and private port forwarding are configured.\n'
printf 'Browser credentials:\n'
cat "$config_dir/.env"

if docker info >/dev/null 2>&1; then
  web run
else
  printf '\nRebuild this Codespace to enable Docker-in-Docker, then run: web run\n'
fi
