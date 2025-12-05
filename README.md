# DevContainer

This repository provides a Docker image for a development environment that installs the build toolchain along with Node.js 22, uv, Bun, pgloader, and the repository code under `/home/workspace`.

## Filesystem layout
- Home directory: `/home`
- Workspace folder: `/workspace`

## Build the image
From the repository root, build the image:

```bash
docker build -t trustable-devcontainer .
```

## Run the container
Set the required/optional environment variables when starting the container:
- `OPS_PASSWORD` (required) – lets `start.sh` write `.env` for the ops IDE and Vite proxy.
- `USERID` (optional, defaults to `1000`) – UID used when creating the `devel` user.
- `SSHKEY` (optional) – public key to allow SSH login to the container.

Forward the necessary ports, including SSH on `2222` and your dev server (e.g., Vite defaults to `5173`). Add any additional ports required by `opencode.sh` or `opsdevel.sh`.

Example:

```bash
docker run -p 2222:2222 -p 5173:5173 \
  -e OPS_PASSWORD=... \
  -e SSHKEY="ssh-rsa ..." \
  trustable-devcontainer
```

After the container starts, `start.sh` generates SSHD host keys, updates `ops`, creates the `devel` user, and launches `supervisord`, which runs `sshd`, `npm run dev`, `opencode.sh`, and `opsdevel.sh`. You can then SSH to `devel` on port `2222` or connect to the dev server via the forwarded port.
