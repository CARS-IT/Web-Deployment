#!/bin/bash
# -----------------------------------------------------------------------------
# Project: Web-Deployment
# File: deploy.sh
# -----------------------------------------------------------------------------
# Purpose: 
# This file is used to deploy/migrate a new WordPress site using Docker.
#
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Docker Compose Configuration
# -----------------------------------------------------------------------------
function deploy_website {
    # Copy the docker-compose-template.yaml file to the site root directory
    cp "$(dirname "$0")/../templates/docker-compose-template.yaml" "$dir_path/docker-compose.yaml"

    # Replace the placeholders in the docker-compose.yaml file
    sed -i "s|db_site_name|db-$converted_site_address|g" "$dir_path/docker-compose.yaml"
    sed -i "s|wordpress_site_name|wp-$converted_site_address|g" "$dir_path/docker-compose.yaml"

    # Deploy the WordPress site
    docker compose -f "$dir_path/docker-compose.yaml" up -d
}

# -----------------------------------------------------------------------------
# Deployment Notices
# -----------------------------------------------------------------------------
function deployment_user_notice {
    echo -e "\n${SEPERATOR_COLOR}------------------------------ Container status ------------------------------${NO_COLOR}"
    # Provide the docker status for the site
    docker compose -f "$dir_path/docker-compose.yaml" ps
    echo -e "${SEPERATOR_COLOR}------------------------------ Container status ------------------------------${NO_COLOR}"

    # Provide the next steps for the user
    echo -e "\n${NOTICE_COLOR}Next Steps${NO_COLOR}"
    echo -ne "
    1. Add the SSL certificate and key to the virtual host configuration file (/etc/httpd/conf.d/10-$converted_site_address.conf)
    2. Restart the Apache server
    3. Add the site to the DNS server
    "
    echo -e "\n${SUCCESS_COLOR}Deployment Complete${NO_COLOR}"
}