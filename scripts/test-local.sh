#!/bin/bash

# Local Testing Script
set -e

echo "🚀 Starting local microservices stack..."

# Build and start services
docker compose up --build -d

echo "⏳ Waiting for services to be ready..."
sleep 30

# Test endpoints
echo "🧪 Testing endpoints..."

echo "Testing Auth Service..."
curl -f http://localhost:3001/health || echo "❌ Auth service not ready"

echo "Testing API Service..."
curl -f http://localhost:3000/health || echo "❌ API service not ready"

echo "Testing Frontend..."
curl -f http://localhost:3080 || echo "❌ Frontend not ready"

echo "✅ Local stack is running!"
echo "📍 Access points:"
echo "   Frontend: http://localhost:3080"
echo "   API: http://localhost:3000"
echo "   Auth: http://localhost:3001"
echo "   Database: localhost:5432"

echo "🛑 To stop: docker compose down"