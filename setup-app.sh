#!/bin/bash
# DigitalOcean App Platform Setup Helper
# Run this after deployment to initialize database and create admin account

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     RealVest - DigitalOcean Setup & Database Initialize        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
for i in {1..30}; do
    if php artisan tinker --execute="DB::connection()->getPdo()" 2>/dev/null; then
        echo -e "${GREEN}✓ Database is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ Database connection failed after 30 attempts${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

echo ""
echo -e "${YELLOW}Running database migrations...${NC}"
php artisan migrate --force --seed

echo ""
echo -e "${GREEN}✓ Database initialized successfully!${NC}"
echo ""

# Display important information
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  🎉 SETUP COMPLETE! 🎉                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}ADMIN LOGIN CREDENTIALS:${NC}"
echo -e "  Email: ${GREEN}admin@site.com${NC}"
echo -e "  Password: ${GREEN}password${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Change admin password on first login!${NC}"
echo ""

echo -e "${BLUE}DATABASE INFORMATION:${NC}"
echo -e "  Host: ${GREEN}${DB_HOST}${NC}"
echo -e "  Port: ${GREEN}${DB_PORT}${NC}"
echo -e "  Database: ${GREEN}${DB_DATABASE}${NC}"
echo -e "  User: ${GREEN}${DB_USERNAME}${NC}"
echo ""

echo -e "${BLUE}APPLICATION LINKS:${NC}"
echo -e "  Admin Panel: ${GREEN}${APP_URL}/admin${NC}"
echo -e "  Login Page: ${GREEN}${APP_URL}/login${NC}"
echo -e "  API: ${GREEN}${APP_URL}/api${NC}"
echo ""

echo -e "${BLUE}ENVIRONMENT:${NC}"
echo -e "  Environment: ${GREEN}${APP_ENV}${NC}"
echo -e "  Debug Mode: ${GREEN}${APP_DEBUG}${NC}"
echo -e "  URL: ${GREEN}${APP_URL}${NC}"
echo ""

echo -e "${BLUE}NEXT STEPS:${NC}"
echo "  1. Visit ${GREEN}${APP_URL}${NC}"
echo "  2. Login with admin credentials above"
echo "  3. Go to Admin Panel → Settings"
echo "  4. Change your password"
echo "  5. Configure payment gateways"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║            Your application is ready to use! 🚀               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
