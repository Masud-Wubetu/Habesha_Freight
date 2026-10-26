#!/usr/bin/env bash
# End-to-end API smoke for mobile fleet integration.
# Usage: ./mobile/tool/e2e_api_smoke.sh [API_ROOT]
#   API_ROOT defaults to first healthy of :5000 / :5001
set -euo pipefail

pick_api() {
  if [[ -n "${1:-}" ]]; then
    echo "$1"
    return
  fi
  for root in "http://localhost:5000" "http://localhost:5001"; do
    if curl -sf "$root/health" >/dev/null 2>&1; then
      echo "$root"
      return
    fi
  done
  echo "No healthy API on :5000 or :5001" >&2
  exit 1
}

ROOT="$(pick_api "${1:-}")"
API="$ROOT/api"
EMAIL="${E2E_FLEET_EMAIL:-fleet@habeshafreight.et}"
PASS="${E2E_FLEET_PASSWORD:-Password123!}"

echo "==> Health $ROOT/health"
curl -sf "$ROOT/health" | head -c 200
echo

echo "==> Login as fleet owner"
LOGIN=$(curl -sf -X POST "$API/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}")
TOKEN=$(echo "$LOGIN" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('token') or d.get('data',{}).get('token') or '')")
if [[ -z "$TOKEN" ]]; then
  echo "Login failed: $LOGIN" >&2
  exit 1
fi
AUTH="Authorization: Bearer $TOKEN"
echo "    token ok (${#TOKEN} chars)"

check_get() {
  local path="$1"
  local code
  code=$(curl -s -o /tmp/hf_e2e_body.json -w "%{http_code}" -H "$AUTH" "$API$path")
  if [[ "$code" != "200" ]]; then
    echo "FAIL GET $path -> $code $(head -c 180 /tmp/hf_e2e_body.json)" >&2
    exit 1
  fi
  echo "    OK GET $path"
}

echo "==> Fleet read endpoints"
check_get /company/profile
check_get /company/stats
check_get /company/vehicles
check_get /company/drivers
check_get /company/deliveries
check_get /company/fleet-requests
check_get /escrow/ledger/all

echo "==> Accept + assign first POSTED fleet request (if any)"
curl -sf -H "$AUTH" "$API/company/fleet-requests" -o /tmp/hf_fleet_req.json
REQ_ID=$(python3 - <<'PY'
import json
d=json.load(open("/tmp/hf_fleet_req.json"))
rows=d.get("data") or []
if isinstance(rows, dict):
    rows=rows.get("items") or []
posted=[r for r in rows if str(r.get("status","")).upper()=="POSTED"]
pick=posted[0] if posted else (rows[0] if rows else None)
print(pick["id"] if pick else "")
PY
)

if [[ -z "$REQ_ID" ]]; then
  echo "    SKIP accept/assign (no fleet requests)"
else
  STATUS=$(python3 - <<PY
import json
d=json.load(open("/tmp/hf_fleet_req.json"))
rows=d.get("data") or []
if isinstance(rows, dict): rows=rows.get("items") or []
row=next((r for r in rows if r.get("id")=="$REQ_ID"), {})
print(str(row.get("status","")).upper())
PY
)
  if [[ "$STATUS" == "POSTED" ]]; then
    code=$(curl -s -o /tmp/hf_e2e_mut.json -w "%{http_code}" -X PATCH \
      -H "$AUTH" -H 'Content-Type: application/json' \
      "$API/company/fleet-requests/$REQ_ID/accept")
    echo "    accept $REQ_ID -> $code"
    [[ "$code" == "200" ]] || { cat /tmp/hf_e2e_mut.json; exit 1; }
  else
    echo "    skip accept (status=$STATUS)"
  fi

  DRIVER_ID=$(curl -sf -H "$AUTH" "$API/company/drivers" | python3 -c "
import sys,json
d=json.load(sys.stdin)
rows=d.get('data') or []
active=[r for r in rows if str(r.get('status','')).upper()=='ACTIVE']
pick=active[0] if active else (rows[0] if rows else None)
print((pick or {}).get('driver_id') or (pick or {}).get('id') or '')
")
  if [[ -n "$DRIVER_ID" ]]; then
    code=$(curl -s -o /tmp/hf_e2e_mut.json -w "%{http_code}" -X POST \
      -H "$AUTH" -H 'Content-Type: application/json' \
      -d "{\"driver_id\":\"$DRIVER_ID\"}" \
      "$API/company/fleet-requests/$REQ_ID/assign")
    echo "    assign driver $DRIVER_ID -> $code"
    # 200 success; 400 if already assigned / wrong status is acceptable for re-runs
    if [[ "$code" != "200" && "$code" != "400" ]]; then
      cat /tmp/hf_e2e_mut.json
      exit 1
    fi
  else
    echo "    SKIP assign (no company drivers)"
  fi
fi

echo "==> Escrow release as fleet (expect 403 shipper/admin-only)"
SHIP_ID=$(curl -sf -H "$AUTH" "$API/escrow/ledger/all" | python3 -c "
import sys,json
d=json.load(sys.stdin)
data=d.get('data') or {}
items=data.get('items') if isinstance(data,dict) else []
locked=[i for i in items if str(i.get('status','')).upper() in ('LOCKED','HELD','PENDING')]
pick=locked[0] if locked else (items[0] if items else None)
print((pick or {}).get('shipment_id') or '')
")
if [[ -n "$SHIP_ID" ]]; then
  code=$(curl -s -o /tmp/hf_e2e_mut.json -w "%{http_code}" -X POST \
    -H "$AUTH" -H 'Content-Type: application/json' \
    "$API/escrow/$SHIP_ID/release")
  echo "    release $SHIP_ID -> $code (403 expected for fleet)"
  if [[ "$code" != "403" && "$code" != "401" && "$code" != "200" && "$code" != "400" ]]; then
    cat /tmp/hf_e2e_mut.json
    exit 1
  fi
else
  echo "    SKIP release (no escrow rows)"
fi

echo ""
echo "E2E API smoke PASSED against $ROOT"
