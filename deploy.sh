#!/bin/bash

# RealVest Automated Deployment Script
# Deploy to DigitalOcean in one command

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}RealVest Deployment Script${NC}"
echo -e "${GREEN}=====================================${NC}\n"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file from .env.production...${NC}"
    cp .env.production .env
    echo -e "${YELLOW}Please edit .env file with your configuration and run this script again.${NC}"
    nano .env
fi

# Validate required environment variables
if grep -q "CHANGE_THIS\|YOUR_" .env; then
    echo -e "${RED}Error: Please update all CHANGE_THIS and YOUR_* values in .env file${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}Creating necessary directories...${NC}"
mkdir -p data/mysql
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Build and start containers
echo -e "${YELLOW}Building Docker images...${NC}"
docker-compose build

echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 30

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
docker-compose exec -T app php artisan migrate --force || true

# Run seeders (optional)
echo -e "${YELLOW}Running database seeders...${NC}"
docker-compose exec -T app php artisan db:seed --force || true

# Set permissions
echo -e "${YELLOW}Setting file permissions...${NC}"
docker-compose exec -T app chmod -R 775 storage logs bootstrap/cache

# Clear caches
echo -e "${YELLOW}Clearing application caches...${NC}"
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan view:clear

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}=====================================${NC}\n"

# Get container status
echo -e "${YELLOW}Service Status:${NC}"
docker-compose ps

# Output access information
echo -e "\n${GREEN}Access Information:${NC}"
echo -e "Application URL: $(grep APP_URL .env | cut -d '=' -f 2)"
echo -e "Database Host: $(grep DB_HOST .env | cut -d '=' -f 2)"

echo -e "\n${YELLOW}Useful Commands:${NC}"
echo -e "View logs: ${GREEN}docker-compose logs -f${NC}"
echo -e "Access container: ${GREEN}docker-compose exec app bash${NC}"
echo -e "Run artisan: ${GREEN}docker-compose exec app php artisan COMMAND${NC}"

