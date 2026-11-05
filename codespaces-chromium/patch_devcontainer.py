#!/usr/bin/env python3
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
env_path = pathlib.Path(sys.argv[2])
workspace_files_dir = pathlib.Path(sys.argv[3]).resolve()
config = json.loads(path.read_text())

features = config.setdefault("features", {})
features.setdefault("ghcr.io/devcontainers/features/docker-in-docker:2", {})

attributes = config.setdefault("portsAttributes", {})
old_browser_config = attributes.get("3000", {}).get("label") == "Chromium browser"
ports = config.setdefault("forwardPorts", [])
if old_browser_config:
    ports[:] = [port for port in ports if port not in (3000, "3000")]
if 3002 not in ports and "3002" not in ports:
    ports.append(3002)

if old_browser_config:
    del attributes["3000"]
browser_port = attributes.setdefault("3002", {})
browser_port.update(
    {
        "label": "Chromium browser",
        "onAutoForward": "openBrowser",
        "visibility": "private",
    }
)

install_command = (
    'sudo install -m 755 "$HOME/.local/share/codespaces-chromium/web" '
    '"$HOME/.local/share/codespaces-chromium/webopen" /usr/local/bin/'
)
post_create = config.get("postCreateCommand")
if isinstance(post_create, str):
    if install_command not in post_create:
        config["postCreateCommand"] = f"{post_create} && {install_command}"
elif post_create is None:
    config["postCreateCommand"] = install_command
elif isinstance(post_create, list):
    if install_command not in post_create:
        post_create.append(install_command)
elif isinstance(post_create, dict):
    post_create.setdefault("installCodespacesChromiumCommands", install_command)
else:
    raise SystemExit("Unsupported postCreateCommand format; update it manually.")

start_command = "docker compose up -d"
post_start = config.get("postStartCommand")
if isinstance(post_start, str):
    if start_command not in post_start:
        config["postStartCommand"] = f"{post_start} && {start_command}"
elif post_start is None:
    config["postStartCommand"] = start_command
elif isinstance(post_start, list):
    if start_command not in post_start:
        post_start.append(start_command)
elif isinstance(post_start, dict):
    post_start.setdefault("startCodespacesChromium", start_command)
else:
    raise SystemExit("Unsupported postStartCommand format; update it manually.")

path.write_text(json.dumps(config, indent=2) + "\n")

env_lines = env_path.read_text().splitlines() if env_path.exists() else []
workspace_entry = f"WORKSPACE_FILES_DIR={json.dumps(str(workspace_files_dir))}"
for index, line in enumerate(env_lines):
    if line.startswith("WORKSPACE_FILES_DIR="):
        env_lines[index] = workspace_entry
        break
else:
    env_lines.append(workspace_entry)
env_path.write_text("\n".join(env_lines) + "\n")
