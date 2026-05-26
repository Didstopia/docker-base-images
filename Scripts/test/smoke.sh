#!/usr/bin/env bash
#
# Smoke tests for the locally loaded base images. Used both in CI and by hand.
# Only tests tags that are actually present locally, so it works whether you
# loaded one image or the whole set. Fails if a present image misbehaves.
#
# Usage:
#   ./Scripts/test/smoke.sh                 # tests didstopia/base:* tags
#   REGISTRY=ghcr.io/didstopia/base ./Scripts/test/smoke.sh

set -u

REGISTRY="${REGISTRY:-didstopia/base}"
read -r -a UBUNTU_VERSIONS <<< "${UBUNTU_VERSIONS:-22.04 24.04}"
read -r -a ALPINE_VERSIONS <<< "${ALPINE_VERSIONS:-3.22 3.23 edge}"
read -r -a NODE_VERSIONS <<< "${NODE_VERSIONS:-22 24}"

PASS=0
FAIL=0
SKIP=0

have() { docker image inspect "$1" >/dev/null 2>&1; }
ok()   { echo "  PASS: $1"; PASS=$((PASS + 1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip() { echo "  skip: $1 (not loaded)"; SKIP=$((SKIP + 1)); }

# run_grep <label> <expected-regex> <docker run args including image and command>
run_grep() {
  local label="$1" want="$2"; shift 2
  local out
  out="$(docker run --rm "$@" 2>/dev/null)" || true
  if printf '%s\n' "$out" | grep -Eq "$want"; then
    ok "$label"
  else
    no "$label (got: $(printf '%s' "$out" | tail -1))"
  fi
}

test_base() {
  local image="$1"
  have "$image" || { skip "$image"; return; }
  # Entrypoint drops to the docker user
  run_grep "$image -> drops to docker" '^docker$' "$image" whoami
  # PUID/PGID remap is honoured
  run_grep "$image -> remaps to PUID 1567" 'uid=1567' -e PUID=1567 -e PGID=1567 "$image" id
}

test_node() {
  local image="$1" major="$2"
  have "$image" || { skip "$image"; return; }
  if [ -n "$major" ]; then
    run_grep "$image -> node v${major}.x" "^v${major}\." --entrypoint node "$image" -v
  else
    run_grep "$image -> node present" '^v[0-9]+\.' --entrypoint node "$image" -v
  fi
}

test_go() {
  local image="$1"
  have "$image" || { skip "$image"; return; }
  run_grep "$image -> go toolchain" 'go version go' --entrypoint /usr/local/go/bin/go "$image" version
}

test_steamcmd() {
  local image="$1"
  have "$image" || { skip "$image"; return; }
  run_grep "$image -> steamcmd present" 'steamcmd.sh' --entrypoint sh "$image" -c 'ls /steamcmd/steamcmd.sh'
}

test_wine() {
  local image="$1"
  have "$image" || { skip "$image"; return; }
  run_grep "$image -> wine present" '^wine-[0-9]' --entrypoint wine "$image" --version
}

test_static() {
  local image="$1" port="$2"
  have "$image" || { skip "$image"; return; }
  local cid
  cid="$(docker run -d -p "${port}:80" "$image" 2>/dev/null)" || { no "$image -> failed to start"; return; }
  sleep 3
  docker exec "$cid" sh -c 'echo smoke-ok > /var/www/html/index.html' >/dev/null 2>&1
  sleep 1
  if curl -fsS "http://localhost:${port}/" 2>/dev/null | grep -q "smoke-ok"; then
    ok "$image -> serves on :80"
  else
    no "$image -> did not serve (logs: $(docker logs "$cid" 2>&1 | tail -1))"
  fi
  docker rm -f "$cid" >/dev/null 2>&1
}

echo "== Ubuntu bases =="
for v in "${UBUNTU_VERSIONS[@]}"; do test_base "${REGISTRY}:ubuntu-${v}"; done

echo "== Ubuntu Node.js =="
for v in "${UBUNTU_VERSIONS[@]}"; do
  for n in "${NODE_VERSIONS[@]}"; do test_node "${REGISTRY}:nodejs-${n}-ubuntu-${v}" "$n"; done
done

echo "== Ubuntu SteamCMD (amd64) =="
for v in "${UBUNTU_VERSIONS[@]}"; do
  test_steamcmd "${REGISTRY}:steamcmd-ubuntu-${v}"
  for n in "${NODE_VERSIONS[@]}"; do test_node "${REGISTRY}:nodejs-${n}-steamcmd-ubuntu-${v}" "$n"; done
done

echo "== Ubuntu Wine + SteamCMD (amd64) =="
for v in "${UBUNTU_VERSIONS[@]}"; do
  test_wine "${REGISTRY}:wine-steamcmd-ubuntu-${v}"
  for n in "${NODE_VERSIONS[@]}"; do
    test_node "${REGISTRY}:nodejs-${n}-wine-steamcmd-ubuntu-${v}" "$n"
    test_wine "${REGISTRY}:nodejs-${n}-wine-steamcmd-ubuntu-${v}"
  done
done

echo "== Alpine bases =="
for v in "${ALPINE_VERSIONS[@]}"; do test_base "${REGISTRY}:alpine-${v}"; done

echo "== Alpine Node.js =="
for v in "${ALPINE_VERSIONS[@]}"; do test_node "${REGISTRY}:nodejs-alpine-${v}" ""; done

echo "== Alpine Go =="
for v in "${ALPINE_VERSIONS[@]}"; do test_go "${REGISTRY}:go-alpine-${v}"; done

echo "== static (Ubuntu + Alpine) =="
port=8200
for v in "${UBUNTU_VERSIONS[@]}"; do test_static "${REGISTRY}:static-ubuntu-${v}" "$port"; port=$((port + 1)); done
for v in "${ALPINE_VERSIONS[@]}"; do test_static "${REGISTRY}:static-alpine-${v}" "$port"; port=$((port + 1)); done

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed, ${SKIP} skipped"
[ "$FAIL" -eq 0 ]
