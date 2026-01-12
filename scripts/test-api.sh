#!/bin/bash

# API Testing Script
BASE_URL="http://localhost"
AUTH_URL="${BASE_URL}:3001"
API_URL="${BASE_URL}:3000"

echo "🧪 Testing Microservices API..."

# Test health endpoints
echo "1. Testing health endpoints..."
curl -s "${AUTH_URL}/health" | jq '.' || echo "❌ Auth health failed"
curl -s "${API_URL}/health" | jq '.' || echo "❌ API health failed"

# Test user registration
echo "2. Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST "${AUTH_URL}/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }')

echo $REGISTER_RESPONSE | jq '.'
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')

# Test user login
echo "3. Testing user login..."
LOGIN_RESPONSE=$(curl -s -X POST "${AUTH_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

echo $LOGIN_RESPONSE | jq '.'

# Test protected API endpoints
echo "4. Testing protected endpoints..."
curl -s "${API_URL}/api/profile" \
  -H "Authorization: Bearer ${TOKEN}" | jq '.' || echo "❌ Profile endpoint failed"

curl -s "${API_URL}/api/users" \
  -H "Authorization: Bearer ${TOKEN}" | jq '.' || echo "❌ Users endpoint failed"

echo "✅ API testing completed!"