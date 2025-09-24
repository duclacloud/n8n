#!/bin/bash
echo "📊 N8N Status:"
echo "=============="
docker compose ps
echo ""
echo "💾 Resource Usage:"
docker stats --no-stream n8n 2>/dev/null || echo "N8N container not running"
echo ""
echo "🌐 Health Check:"
curl -s http://localhost:5678/healthz >/dev/null && echo "✅ N8N is healthy" || echo "❌ N8N is not responding"