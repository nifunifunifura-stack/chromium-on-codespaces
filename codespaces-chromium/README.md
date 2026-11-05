# Install in another Codespace

Run this one command from a terminal in the target repository. It downloads
this public repository and configures the current Codespace workspace:

```sh
curl -fsSL https://raw.githubusercontent.com/nifunifunifura-stack/chromium-on-codespaces/main/install.sh | bash
```

The setup preserves existing Dev Container settings, enables Docker-in-Docker,
configures private forwarding for port 3000, and sets the browser username and
password to `1234` in the Git-ignored `.codespaces-chromium/.env` file. The
credentials are printed by the setup script. Runtime configuration and the
browser profile are stored in Git-ignored workspace folders
(`.codespaces-chromium/` and `browser-data/`) so they survive Dev Container
rebuilds of the same Codespace. Do not commit these folders: they contain
credentials, cookies, and browser state. Deleting the Codespace does not
preserve ignored workspace data; back it up securely before deleting the
Codespace. Websites may still expire or revoke sessions independently. The
browser container itself is recreated during a rebuild and starts automatically
with the saved profile; its container ID does not persist. Chromium's
crash-recovery prompt is disabled, and Docker is given time to stop the browser
cleanly. Touchpad and wheel scroll input is reduced to half speed in the
remote desktop client.
The browser container uses the Codespace host network because Docker bridge egress is unavailable in this environment. Port 3000 is forwarded privately by Codespaces. Host networking lets the browser container access services listening on the Codespace, including localhost services, so keep the port private and protect the browser credentials.

If Docker is not available yet, use **Codespaces: Rebuild Container** once to
apply the Docker feature. Then run `web run`. Codespaces opens the forwarded
browser port automatically; if it does not, open port 3000 from the Ports tab.

Place files you want to use in the browser in `browser-files/`. In Chromium's
file picker, open `/workspace` to select them. The folder is read-only inside
the browser container, and its contents are excluded from Git. To transfer a
file from your own device instead, use the browser session's Upload control.

The browser desktop includes a terminal. Keep its Codespaces port private and
do not share its credentials. The browser remains subject to network rules and
the destination sites' access policies.
