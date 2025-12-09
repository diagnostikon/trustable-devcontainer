#!/bin/bash
cd /home/opencode/
bun install
bun run --watch --cwd packages/opencode --conditions=browser src/index.ts serve --port 4096 --hostname 0.0.0.0  --log-level DEBUG --print-logs --directory /home/workspace
