# Install in another Codespace

Run this one command from a terminal in the target repository. It downloads
this public repository and configures the current Codespace workspace:

```sh
curl -fsSL https://raw.githubusercontent.com/nifunifunifura-stack/chromium-on-codespaces/main/install.sh | bash
```

The setup preserves existing Dev Container settings, enables Docker-in-Docker,
configures private HTTPS forwarding for port 6901, and sets the browser password
to `1234` in the Git-ignored `.codespaces-chromium/.env` file. The username is
`kasm_user`; credentials are printed by the setup script. Runtime configuration
and the Chrome profile are stored in Git-ignored workspace folders
(`.codespaces-chromium/` and `browser-data/`) so they survive Dev Container
rebuilds of the same Codespace. Do not commit these folders: they contain
credentials, cookies, and browser state. Deleting the Codespace does not
preserve ignored workspace data; back it up securely before deleting the
Codespace. Websites may still expire or revoke sessions independently. The
browser container itself is recreated during a rebuild and starts automatically
with the saved profile; its container ID does not persist. When switching from
Chromium, its existing profile is not imported automatically, so you may need to
sign in again. Chrome's crash-recovery prompt is disabled, and Docker is given
time to stop the browser cleanly. The browser container uses the Codespace host
network because Docker bridge egress is unavailable in this environment. Port
6901 is forwarded privately by Codespaces. Host networking lets the browser
container access services listening on the Codespace, including localhost
services, so keep the port private and protect the browser credentials.

If Docker is not available yet, use **Codespaces: Rebuild Container** once to
apply the Docker feature. Then run `web run`. Codespaces opens the forwarded
browser port automatically; if it does not, open port 6901 from the Ports tab.

Place files you want to use in the browser in `browser-files/`. In Chrome's file
picker, open `/workspace` to select them. The folder is read-only inside the
browser container, and its contents are excluded from Git. Downloaded files are
available in `browser-data/Downloads/`.

The browser desktop includes a terminal. Keep its Codespaces port private and
do not share its credentials. The browser remains subject to network rules and
the destination sites' access policies.
