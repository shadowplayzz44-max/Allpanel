#!/bin/bash

# Visual Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}=============================================${NC}"
echo -e "${GREEN}      PANEL INSTALLATION MENU (2026)         ${NC}"
echo -e "${CYAN}=============================================${NC}"
echo -e "${YELLOW}Please select what you want to install:${NC}"
echo ""
echo -e "1) Pterodactyl Panel (Game Servers)"
echo -e "2) Convoy Panel (KVM/Virtual Machines)"
echo -e "3) Exit"
echo ""
read -p "Enter your choice [1 or 2]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Starting Pterodactyl Panel Installation...${NC}"
        sleep 2
        # Official Pterodactyl Installation Script
        bash <(curl -s https://pterodactyl-installer.se)
        ;;

    2)
        echo -e "\n${GREEN}Starting Convoy Panel Installation...${NC}"
        sleep 2
        
        # Dependencies for Convoy
        apt update && apt upgrade -y
        apt install -y curl tar unzip git
        
        # Docker Installation
        if ! command -v docker &> /dev/null; then
            echo "Installing Docker..."
            curl -sSL https://get.docker.com/ | CHANNEL=stable sh
            systemctl enable --now docker
        fi

        # Convoy Setup
        mkdir -p /var/www/convoy
        cd /var/www/convoy
        curl -Lo panel.tar.gz https://github.com/convoypanel/panel/releases/latest/download/panel.tar.gz
        tar -xzvf panel.tar.gz
        chmod -R 755 storage bootstrap/cache
        cp .env.example .env
        
        echo -e "\n${YELLOW}Convoy files downloaded to /var/www/convoy${NC}"
        echo -e "Ab aapko '.env' file edit karni hai aur 'docker compose up -d' run karna hai."
        ;;

    3)
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo -e "${YELLOW}Invalid option! Please run the script again and choose 1 or 2.${NC}"
        ;;
esac
