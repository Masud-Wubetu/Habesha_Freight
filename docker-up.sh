#!/usr/bin/env bash
# Start Habesha Freight stack with Docker Compose (works even when Cursor AppImage breaks PATH).
set -euo pipefail
cd "$(dirname "$0")"
chmod +x backend/docker-entrypoint.sh 2>/dev/null || true

COMPOSE=(env -i PATH=/usr/bin:/bin:/usr/local/bin HOME="$HOME" DOCKER_HOST="${DOCKER_HOST:-}" /usr/local/bin/docker-compose)

echo "==> Building and starting Habesha Freight (postgres + backend + frontend)"
"${COMPOSE[@]}" -f docker-compose.yml up -d --build "$@"

echo ""
echo "Waiting for backend health..."
for i in $(seq 1 60); do
  if curl -sf http://127.0.0.1:5001/health >/dev/null 2>&1; then
    echo "✅ Backend is healthy"
    break
  fi
  sleep 2
done

echo ""
echo "Endpoints:"
echo "  Website:  http://localhost:3001"
echo "  API:      http://localhost:5001/api"
echo "  Health:   http://localhost:5001/health"
echo "  Postgres: localhost:5434 (postgres / postgrespassword)"
echo ""
echo "Demo login: fleet@habeshafreight.et / Password123!"
echo "Logs: env -i PATH=/usr/bin:/bin:/usr/local/bin HOME=\$HOME /usr/local/bin/docker-compose -f docker-compose.yml logs -f"
