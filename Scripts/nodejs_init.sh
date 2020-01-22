#!/usr/bin/env bash

set -e
set -o pipefail

echo "Initializing Node.js support.."

cd "/app" ||
{
    echo "Application directory is missing: /app"
    exit 1
}

if [ -f /app/package.json ]; then
    echo "Installing dependencies.."
    cd /app
    npm install
    if jq -e ".scripts.build" package.json >/dev/null; then
        echo "Building.."
        npm run build
    fi
    if jq -e ".scripts.start" package.json >/dev/null; then
        echo "Starting.."
        npm start
    else
        echo "Application configuration is missing 'start' script: /app/package.json"
        exit 1
    fi
else
    echo "Application configuration is missing: /app/package.json"
    exit 1
fi
