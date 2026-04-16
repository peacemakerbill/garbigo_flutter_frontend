#!/usr/bin/env bash
# ============================================================
# Garbigo Frontend – Flutter Web Runner
# ------------------------------------------------------------
# Project       : Garbigo - Smart Waste Management Platform
# Description   : Flutter web launcher for garbage collection
# Author        : Peacemaker Bill
# Repository    : https://github.com/peacemakerbill/garbigo_flutter_frontend
# ============================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Clear screen
clear

# Logo
echo -e "${GREEN}"
cat << "EOF"
   ____            _     _
  / ___| __ _ _ __| |__ (_)_ __   ___
 | |  _ / _` | '__| '_ \| | '_ \ / _ \
 | |_| | (_| | |  | |_) | | | | | (_) |
  \____|\__,_|_|  |_.__/|_|_| |_|\___/

        ♻️  Smart Waste Management  ♻️
EOF
echo -e "${RESET}"
echo -e "${CYAN}Garbigo Frontend - Flutter Web${RESET}"
echo -e "${YELLOW}Making cities cleaner, greener, and more efficient${RESET}\n"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter SDK${RESET}"
    exit 1
fi

# Check if in project directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Not in Garbigo project directory (pubspec.yaml missing)${RESET}"
    exit 1
fi

# Get dependencies
echo -e "${BLUE}📦 Installing dependencies...${RESET}"
flutter pub get

# Enable web if not already
if ! flutter config --list | grep -q "web: enabled"; then
    echo -e "${BLUE}🌐 Enabling web support...${RESET}"
    flutter config --enable-web
fi

# Detect browser
if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
    BROWSER="chrome"
    echo -e "${GREEN}✓ Browser: Chrome detected${RESET}"
elif command -v chromium &> /dev/null; then
    BROWSER="chrome"
    echo -e "${GREEN}✓ Browser: Chromium detected${RESET}"
elif command -v firefox &> /dev/null; then
    BROWSER="firefox"
    echo -e "${GREEN}✓ Browser: Firefox detected${RESET}"
else
    echo -e "${YELLOW}⚠️  No browser detected. Using Chrome device (requires Chrome/Chromium)${RESET}"
    BROWSER="chrome"
fi

echo -e "${GREEN}🚀 Starting Garbigo Web App...${RESET}"
echo -e "${CYAN}📍 Port: 3000${RESET}"
echo -e "${CYAN}🌍 URL: http://localhost:3000${RESET}\n"

# Run the app
flutter run -d "$BROWSER" --web-port=3000