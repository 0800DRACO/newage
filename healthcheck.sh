#!/bin/bash

# Health check script for RealVest
echo "Checking RealVest Health..."
echo "============================"

FAILED=0

# Check Docker containers
echo "1. Checking Docker containers..."
if docker-compose ps | grep -q "Exit"; then
    echo "❌ Some containers have exited"
    docker-compose ps
    FAILED=1
else
    echo "✓ All containers are running"
fi

# Check database connection
echo ""
echo "2. Checking database connection..."
if docker-compose exec -T app php artisan tinker <<< "exit" 2>&1 | grep -q "error"; then
    echo "❌ Database connection failed"
    FAILED=1
else
    echo "✓ Database connection OK"
fi

# Check logs for errors
echo ""
echo "3. Checking logs for errors..."
ERROR_COUNT=$(docker-compose logs app | grep -i "error" | wc -l)
if [ $ERROR_COUNT -gt 5 ]; then
    echo "⚠️  Found $ERROR_COUNT errors in logs"
else
    echo "✓ Logs look healthy"
fi

# Summary
echo ""
echo "============================"
if [ $FAILED -eq 0 ]; then
    echo "✓ All health checks passed!"
    exit 0
else
    echo "❌ Some health checks failed"
    exit 1
fi
