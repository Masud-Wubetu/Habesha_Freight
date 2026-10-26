#!/bin/sh
set -e

echo "⏳ Waiting for database ${DB_HOST:-postgres}:${DB_PORT:-5432}..."
i=0
until node -e "
const net=require('net');
const s=net.connect(${DB_PORT:-5432}, '${DB_HOST:-postgres}', ()=>{s.end(); process.exit(0)});
s.on('error', ()=>process.exit(1));
" 2>/dev/null; do
  i=$((i+1))
  if [ "$i" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"
    exit 1
  fi
  sleep 1
done
echo "✅ Database port is open"

echo "📦 Running migrations..."
npx tsx node_modules/knex/bin/cli.js migrate:latest --knexfile knexfile.ts --env production

SHOULD_SEED="${SEED_ON_START:-false}"
if [ "$SHOULD_SEED" = "auto" ]; then
  COUNT=$(node -e "
  const {Client}=require('pg');
  const c=new Client({
    host: process.env.DB_HOST||'postgres',
    port: Number(process.env.DB_PORT||5432),
    database: process.env.DB_NAME||'habesha_freight',
    user: process.env.DB_USER||'postgres',
    password: process.env.DB_PASSWORD||'postgrespassword',
  });
  c.connect().then(()=>c.query('select count(*)::int as n from users'))
    .then(r=>{ console.log(r.rows[0].n); return c.end(); })
    .catch(async e=>{ console.log('0'); try{await c.end()}catch(_){ } });
  " 2>/dev/null || echo 0)
  if [ "${COUNT:-0}" = "0" ]; then
    SHOULD_SEED=true
    echo "🌱 Empty users table — auto-seeding demo data"
  else
    SHOULD_SEED=false
    echo "ℹ️  Users already present ($COUNT) — skipping seed"
  fi
fi

if [ "$SHOULD_SEED" = "true" ]; then
  echo "🌱 Seeding demo data..."
  npx tsx node_modules/knex/bin/cli.js seed:run --knexfile knexfile.ts --env production || {
    echo "⚠️ Seed failed — continuing"
  }
fi

echo "🚀 Starting API server..."
exec node dist/server.js
