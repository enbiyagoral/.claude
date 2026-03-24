#!/bin/bash
# Container status summary — shows health state of all containers
# The scripts/ folder inside skills keeps deterministic tasks fixed
# so Claude doesn't have to recreate them each time.
# This saves tokens and ensures consistency.

echo "=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker daemon not running"

echo ""
echo "=== Recently Stopped ==="
docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}" 2>/dev/null | head -10

echo ""
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | head -10

echo ""
echo "=== Disk Usage ==="
docker system df 2>/dev/null