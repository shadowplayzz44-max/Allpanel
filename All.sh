#!/bin/bash

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Addons Sub-Menu ---
install_addon() {
    clear
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}       PTERODACTYL ADDONS (Via Blueprint)    ${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo -e "1) Player Manager"
    echo -e "2) Subdomain Manager"
    echo -e "3) World Manager"
    echo -e "4) Nebula Theme"
    echo -e "5) Plugin Installer"
    echo -e "6) Back to Main Menu"
    echo ""
    read -p "Select Addon to Install: " addon_choice

    case $addon_choice in
        1) echo -e "${YELLOW}Installing Player Manager...${NC}"
           blueprint -i playermanager ;;
        2) echo -e "${YELLOW}Installing Subdomain Manager...${NC}"
           blueprint -i subdomainmanager ;;
        3) echo -e "${YELLOW}Installing World Manager...${NC}"
           blueprint -i worldmanager ;;
        4) echo -e "${YELLOW}Installing Nebula Theme...${NC}"
           blueprint -i nebula ;;
        5) echo -e "${YELLOW}Installing Plugin Installer...${NC}"
           blueprint -i plugininstaller ;;
        6) return ;;
        *) echo -e "${RED}Invalid!${NC}" ; sleep 1 ; install_addon ;;
    esac
    echo -e "${GREEN}Process Completed!${NC}"
    sleep 2
}

# --- Blueprint Installer Function ---
install_blueprint() {
    echo -e "${YELLOW}Installing Blueprint Framework...${NC}"
    cd /var/www/pterodactyl
    # Installing dependencies
    apt install -y icecast2 liblua5.3-0
    # Downloading & Installing Blueprint
    curl -L https://github.com/BlueprintFramework/framework/releases/latest/download/blueprint.sh | bash
    echo -e "${GREEN}Blueprint Framework Installed Successfully!${NC}"
    sleep 2
}

# --- Main Menu ---
show_menu() {
    clear
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}    ADVANCED MULTI-PANEL SCRIPT (2026)       ${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo -e "1) Install Pterodactyl Panel"
    echo -e "2) Install Pterodactyl Wings"
    echo -e "3) Install Convoy Panel"
    echo -e "4) Install Blueprint Framework (Required for Addons)"
    echo -e "5) Pterodactyl Addons Menu"
    echo -e "6) Exit"
    echo ""
    read -p "Choose an option [1-6]: " main_choice

    case $main_choice in
        1) bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
EOF
        ;;
        2) bash <(curl -s https://pterodactyl-installer.se) <<EOF
1
EOF
        ;;
        3) # Convoy Basic Setup
           apt update && apt install -y curl tar
           mkdir -p /var/www/convoy && cd /var/www/convoy
           curl -Lo panel.tar.gz https://github.com/convoypanel/panel/releases/latest/download/panel.tar.gz
           tar -xzvf panel.tar.gz
           echo -e "${GREEN}Convoy files downloaded!${NC}"; sleep 2
        ;;
        4) install_blueprint ;;
        5) # Check if Blueprint is installed first
           if command -v blueprint &> /dev/null; then
               install_addon
           else
               echo -e "${RED}Error: Please install Blueprint Framework (Option 4) first!${NC}"
               sleep 3
           fi
        ;;
        6) exit 0 ;;
        *) echo -e "${RED}Invalid Selection!${NC}" ; sleep 1 ; show_menu ;;
    esac
}

# Loop the menu
while true; do
    show_menu
done
