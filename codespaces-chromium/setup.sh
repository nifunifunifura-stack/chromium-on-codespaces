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
install_dir="${HOME}/.local/share/codespaces-chromium"
config_dir="${HOME}/.config/codespaces-chromium"
workspace_files_dir="$PWD/browser-files"

mkdir -p "$install_dir" "$config_dir" "$workspace_files_dir" "$PWD/browser-data"
touch "$PWD/.gitignore"
if ! grep -qxF '/browser-data/' "$PWD/.gitignore"; then
  printf '\n/browser-data/\n' >> "$PWD/.gitignore"
fi
install -m 644 "$source_dir/docker-compose.yml" "$install_dir/docker-compose.yml"
install -m 755 "$source_dir/webopen" "$install_dir/webopen"
install -m 755 "$source_dir/web" "$install_dir/web"

if [[ ! -f "$config_dir/.env" ]]; then
  if ! command -v openssl >/dev/null 2>&1; then
    printf 'openssl is required to generate a browser password.\n' >&2
    exit 1
  fi
  umask 077
  printf 'BROWSER_USER=browser\nBROWSER_PASSWORD=%s\n' "$(openssl rand -hex 24)" > "$config_dir/.env"
fi
chmod 600 "$config_dir/.env"

python3 "$source_dir/patch_devcontainer.py" \
  "$PWD/.devcontainer/devcontainer.json" \
  "$config_dir/.env" \
  "$workspace_files_dir"
sudo install -m 755 "$install_dir/web" "$install_dir/webopen" /usr/local/bin/

printf 'Setup files and private port forwarding are configured.\n'
printf 'Browser credentials:\n'
sed 's/^BROWSER_PASSWORD=/BROWSER_PASSWORD=/' "$config_dir/.env"

if docker info >/dev/null 2>&1; then
  web run
else
  printf '\nRebuild this Codespace to enable Docker-in-Docker, then run: web run\n'
fi
