#!/usr/bin/env python3
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
env_path = pathlib.Path(sys.argv[2])
workspace_files_dir = pathlib.Path(sys.argv[3]).resolve()
browser_data_dir = pathlib.Path(sys.argv[4]).resolve()
config = json.loads(path.read_text())

features = config.setdefault("features", {})
features.setdefault("ghcr.io/devcontainers/features/docker-in-docker:2", {})

attributes = config.setdefault("portsAttributes", {})
ports = config.setdefault("forwardPorts", [])
browser_configured_port = next(
    (
        port
        for port in ("3000", "3002")
        if attributes.get(port, {}).get("label") == "Chromium browser"
    ),
    None,
)
if browser_configured_port is not None:
    ports[:] = [port for port in ports if str(port) != browser_configured_port]
    if browser_configured_port != "3000":
        del attributes[browser_configured_port]
if 3000 not in ports and "3000" not in ports:
    ports.append(3000)

browser_port = attributes.setdefault("3000", {})
browser_port.update(
    {
        "label": "Chromium browser",
        "onAutoForward": "openBrowser",
        "visibility": "private",
    }
)

install_command = (
    'sudo install -m 755 .codespaces-chromium/web '
    '.codespaces-chromium/webopen /usr/local/bin/'
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

start_command = "webopen"
legacy_start_command = "docker compose up -d"
post_start = config.get("postStartCommand")
if isinstance(post_start, str):
    if post_start == legacy_start_command:
        config["postStartCommand"] = start_command
    elif post_start.endswith(f" && {legacy_start_command}"):
        config["postStartCommand"] = (
            f"{post_start[: -len(legacy_start_command)]}{start_command}"
        )
    elif start_command not in post_start:
        config["postStartCommand"] = f"{post_start} && {start_command}"
elif post_start is None:
    config["postStartCommand"] = start_command
elif isinstance(post_start, list):
    if start_command not in post_start:
        post_start.append(start_command)
elif isinstance(post_start, dict):
    if post_start.get("startCodespacesChromium") == legacy_start_command:
        post_start["startCodespacesChromium"] = start_command
    else:
        post_start.setdefault("startCodespacesChromium", start_command)
else:
    raise SystemExit("Unsupported postStartCommand format; update it manually.")

path.write_text(json.dumps(config, indent=2) + "\n")

env_lines = env_path.read_text().splitlines() if env_path.exists() else []
for key, value in (
    ("WORKSPACE_FILES_DIR", workspace_files_dir),
    ("WORKSPACE_BROWSER_DATA_DIR", browser_data_dir),
):
    entry = f"{key}={json.dumps(str(value))}"
    for index, line in enumerate(env_lines):
        if line.startswith(f"{key}="):
            env_lines[index] = entry
            break
    else:
        env_lines.append(entry)
env_path.write_text("\n".join(env_lines) + "\n")
