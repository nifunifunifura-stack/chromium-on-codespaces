# Codespaces Chromium

This workspace runs a Chromium desktop in a separate container and forwards its
web interface through a private Codespaces port.

## Start

1. Rebuild the Codespace using **Codespaces: Rebuild Container** so the Docker-in-Docker feature is installed.
2. Copy `.env.example` to `.env` and set `BROWSER_PASSWORD` to a strong, unique password (for example, generate one with `openssl rand -hex 24`). Do not commit `.env`.
3. Run `web run` in the workspace terminal. It starts Chromium; Codespaces opens the forwarded browser port automatically.
4. Sign in with the credentials from `.env`. If the browser does not open automatically, open forwarded port **3002** from the Codespaces Ports tab.

The browser starts automatically whenever the Codespace starts. Stop it with `docker compose down`. Its browser profile (including browser account sign-ins and cookies) is stored in the workspace's ignored `browser-data/` folder, so it survives a Dev Container rebuild of this Codespace. The browser container itself is recreated by a rebuild, then started automatically with the saved profile; its container ID does not persist. Chromium's crash-recovery prompt is disabled, and Docker is given time to stop the browser cleanly. Keep `browser-data/` out of Git because browser profiles contain sensitive credentials and cookies. Deleting the Codespace or creating a different one does not preserve this ignored folder; back it up securely before deleting the Codespace. Websites may still expire or revoke sessions independently.

The `web` command is installed when the Codespace is created; after adding this command to an existing Codespace, run **Codespaces: Rebuild Container** once.

Place files you want to use in the browser in `browser-files/`; they are mounted read-only at `/workspace`. The browser file picker can open that folder. Files in it are excluded from Git.

The forwarded port is configured as **private**, and the service binds only to the Codespace's loopback interface. Keep it private and use it only for sites and networks you are authorized to access. The container's web desktop includes a terminal, so protect the password and stop the service when it is not in use. Access to external sites remains subject to Codespaces network rules and those sites' own restrictions.

Port 3002 is forwarded to the browser's internal HTTP port 3000. The Docker port is published on all Codespace interfaces so the Codespaces forwarding proxy can reach it; Codespaces port visibility remains private.

To install this setup into another Codespace, copy the `codespaces-chromium` folder there and run `bash codespaces-chromium/setup.sh` from that workspace root. See [codespaces-chromium/README.md](./codespaces-chromium/README.md).
