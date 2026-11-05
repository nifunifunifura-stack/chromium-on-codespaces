# Install in another Codespace

Copy this `codespaces-chromium` folder into the root of the target Codespace
workspace, then run this single command from that workspace root:

```sh
bash codespaces-chromium/setup.sh
```

The setup preserves existing Dev Container settings, enables Docker-in-Docker,
configures private forwarding for port 3002, installs `web` / `webopen`, and
generates a unique browser password under `~/.config/codespaces-chromium/`.
The generated credentials are printed by the setup script. It also creates a
`browser-files/` folder in the workspace and mounts only that folder into the
browser as read-only at `/workspace`. The browser profile, including account
sign-ins and cookies, is stored in the Git-ignored workspace folder
`browser-data/`, rather than a Docker-managed volume, so it survives Dev
Container rebuilds of the same Codespace. The browser container itself is
recreated during a rebuild, then started automatically with the saved profile;
its container ID does not persist. Chromium's crash-recovery prompt is
disabled, and Docker is given time to stop the browser cleanly. Keep this
folder out of Git because it contains sensitive credentials and cookies.
Deleting the Codespace does not preserve this ignored folder; back it up
securely before deleting the Codespace. Websites may still expire or revoke
sessions independently. The browser container is automatically recreated
whenever the Codespace starts.
Port 3002 on the Codespace maps to the browser container's HTTP port 3000 and is configured for private Codespaces forwarding.

If Docker is not available yet, use **Codespaces: Rebuild Container** once to
apply the Docker feature. Then run `web run`. Codespaces opens the forwarded
browser port automatically; if it does not, open port 3002 from the Ports tab.

Place files you want to use in the browser in `browser-files/`. In Chromium's
file picker, open `/workspace` to select them. The folder is read-only inside
the browser container, and its contents are excluded from Git. To transfer a
file from your own device instead, use the browser session's Upload control.

The browser desktop includes a terminal. Keep its Codespaces port private and
do not share its credentials. The browser remains subject to network rules and
the destination sites' access policies.
