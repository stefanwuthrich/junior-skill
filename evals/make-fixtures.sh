#!/usr/bin/env bash
# Builds a scratch git repo with the /junior eval fixtures as tagged commits,
# plus seeded learning logs. Usage: evals/make-fixtures.sh <empty-dir>
#
#   fx-decision  one real decision: retry with an idempotency key
#   fx-rename    tiny diff, zero decisions: variable rename
#   fx-multi     multi-file: a TTL cache wired into a service, with a test
#
# Logs (in <dir>/logs/): log-open.md has an open concept older than 3 days;
# log-401.md has 401 lines whose oldest line is the only line of an open slug.
set -euo pipefail

dir=${1:?usage: make-fixtures.sh <empty-dir>}
mkdir -p "$dir" && cd "$dir"
[ -z "$(ls -A)" ] || { echo "not empty: $dir" >&2; exit 1; }

git init -q -b main
git config user.email eval@example.invalid
git config user.name eval

mkdir -p shop tests
cat > shop/payments.py <<'EOF'
import requests

API = "https://pay.example.invalid/charge"


def charge(order):
    resp = requests.post(API, json={"order": order["id"], "amount": order["amount"]}, timeout=5)
    resp.raise_for_status()
    return resp.json()["charge_id"]
EOF
cat > shop/prices.py <<'EOF'
def total(items):
    amt = 0
    for item in items:
        amt += item["price"] * item["qty"]
    return amt
EOF
cat > shop/catalog.py <<'EOF'
import requests


def product(pid):
    return requests.get(f"https://catalog.example.invalid/p/{pid}", timeout=5).json()
EOF
git add -A && git commit -qm "Base shop"

# fx-decision: retries are only safe because the key makes the charge idempotent.
cat > shop/payments.py <<'EOF'
import time
import uuid

import requests

API = "https://pay.example.invalid/charge"
MAX_ATTEMPTS = 3


def charge(order):
    # One key per order: the provider dedupes retries that reuse it.
    key = order.setdefault("idempotency_key", str(uuid.uuid4()))
    for attempt in range(MAX_ATTEMPTS):
        try:
            resp = requests.post(
                API,
                json={"order": order["id"], "amount": order["amount"]},
                headers={"Idempotency-Key": key},
                timeout=5,
            )
            if resp.status_code < 500:
                resp.raise_for_status()
                return resp.json()["charge_id"]
        except requests.ConnectionError:
            pass
        time.sleep(min(2 ** attempt, 4))
    raise RuntimeError(f"charge failed after {MAX_ATTEMPTS} attempts")
EOF
git commit -qam "Retry charges with an idempotency key" && git tag fx-decision

# fx-rename: no decision at all.
sed -i 's/amt/amount/g' shop/prices.py
git commit -qam "Rename amt to amount" && git tag fx-rename

# fx-multi: cache module, service change, test.
cat > shop/cache.py <<'EOF'
import time


class TTLCache:
    def __init__(self, ttl_seconds, max_items=1024):
        self.ttl = ttl_seconds
        self.max_items = max_items
        self._data = {}

    def get(self, key):
        hit = self._data.get(key)
        if hit is None or hit[1] < time.monotonic():
            self._data.pop(key, None)
            return None
        return hit[0]

    def put(self, key, value):
        if len(self._data) >= self.max_items:
            self._data.pop(next(iter(self._data)))
        self._data[key] = (value, time.monotonic() + self.ttl)
EOF
cat > shop/catalog.py <<'EOF'
import requests

from shop.cache import TTLCache

_cache = TTLCache(ttl_seconds=60)


def product(pid):
    cached = _cache.get(pid)
    if cached is not None:
        return cached
    data = requests.get(f"https://catalog.example.invalid/p/{pid}", timeout=5).json()
    _cache.put(pid, data)
    return data
EOF
cat > tests/test_cache.py <<'EOF'
from shop.cache import TTLCache


def test_expired_entry_is_dropped(monkeypatch):
    now = [100.0]
    monkeypatch.setattr("shop.cache.time.monotonic", lambda: now[0])
    c = TTLCache(ttl_seconds=10)
    c.put("a", 1)
    now[0] = 111.0
    assert c.get("a") is None
EOF
git add -A && git commit -qm "Cache catalog lookups for 60s" && git tag fx-multi

mkdir -p logs
cat > logs/log-open.md <<'EOF'
2026-01-05 | shop | quiz | idempotency | missed
2026-01-05 | shop | quiz | exponential-backoff | got-it
2026-01-06 | shop | quiz | cache-invalidation | partial
2026-01-07 | shop | warmup | cache-invalidation | got-it
EOF
{
  echo "2026-01-01 | shop | quiz | lost-update | missed"
  for i in $(seq 1 400); do echo "2026-02-01 | shop | quiz | filler-concept-$((i % 50)) | got-it"; done
} > logs/log-401.md
# logs/ is eval scaffolding, not part of the fixture diffs.
echo "logs/" >> .git/info/exclude

echo "fixtures ready in $dir: tags $(git tag | tr '\n' ' ')"
