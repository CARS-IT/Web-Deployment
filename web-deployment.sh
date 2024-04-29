#!/bin/bash
# -----------------------------------------------------------------------------
# Project: Web-Deployment
# File: web-deployment.sh
# -----------------------------------------------------------------------------
# Purpose: 
# This file acts as the main entry point for the web deployment project.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

# ASCII Header for the script
echo -ne "
------------------------------------------------------------------------------------------------------------------------

                                          ██████╗ █████╗ ██████╗ ███████╗
                                         ██╔════╝██╔══██╗██╔══██╗██╔════╝
                                         ██║     ███████║██████╔╝███████╗
                                         ██║     ██╔══██║██╔══██╗╚════██║
                                         ╚██████╗██║  ██║██║  ██║███████║
                                          ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
██╗    ██╗███████╗██████╗       ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗███╗   ███╗███████╗███╗   ██╗████████╗
██║    ██║██╔════╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
██║ █╗ ██║█████╗  ██████╔╝█████╗██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ ██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
██║███╗██║██╔══╝  ██╔══██╗╚════╝██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
╚███╔███╔╝███████╗██████╔╝      ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
 ╚══╝╚══╝ ╚══════╝╚═════╝       ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝  
 
                                       Semi-Automated Web-Deployment for CARS
------------------------------------------------------------------------------------------------------------------------

"

# Define colors
NOTICE_COLOR="\033[0;31m"
NO_COLOR="\033[0m"

# Check for elevated privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${NOTICE_COLOR}Please run this script with elevated privileges${NO_COLOR}"
    exit 1
fi

# Define directories
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts"

# ASCII Header for the script
# ...

# Print a message
echo -e "${NOTICE_COLOR}AVAILABLE OPTIONS${NO_COLOR}"
echo -e "${NOTICE_COLOR}-----------------${NO_COLOR}"

# Create the menu
while true; do
    echo "1. Add new WordPress site"
    echo "2. Migrate an existing WordPress site"
    echo "3. Exit"

    read -rp "Enter your choice: " choice

    case $choice in
        1)
            bash "$SCRIPTS_DIR/deploy_wordpress_site.sh"
            exit 0
            ;;
        2)
            bash "$SCRIPTS_DIR/migrate_wordpress_site.sh"
            exit 0
            ;;
        3)
            echo "Exiting the script..."
            break
            ;;
        *)
            echo "Invalid option $choice"
            ;;
    esac
done