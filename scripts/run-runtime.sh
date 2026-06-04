#!/bin/sh
set -eu

cleanup() {
	docker compose --profile run down --remove-orphans >/dev/null 2>&1 || true
}

cleanup

main_pid=$$
cwd=$(pwd)

nohup sh -c "
	while kill -0 $main_pid 2>/dev/null; do
		sleep 1
	done
	cd '$cwd'
	docker compose --profile run down --remove-orphans >/dev/null 2>&1 || true
" >/dev/null 2>&1 &
watcher_pid=$!

trap 'kill "$watcher_pid" >/dev/null 2>&1 || true; cleanup' EXIT INT TERM HUP

docker compose --profile run up run