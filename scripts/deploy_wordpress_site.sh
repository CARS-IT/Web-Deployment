#!/bin/bash
# -----------------------------------------------------------------------------
# Project: Web-Deployment
# File: deploy_wordpress_site.sh
# -----------------------------------------------------------------------------
# Purpose: 
# This file is used to configure and deploy a new WordPress site using Docker.
#
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Define directories
SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source scripts
source $SCRIPTS_DIR/prompts.sh
source $SCRIPTS_DIR/files.sh
source $SCRIPTS_DIR/deploy.sh

# Current timestamp
timestamp=$(date +"%Y-%m-%d %T")

# Define colors
NOTICE_COLOR="\033[0;31m"
SEPERATOR_COLOR="\033[0;33m"
SUCCESS_COLOR="\033[0;32m"
NO_COLOR="\033[0m"

echo -e "\n${SEPERATOR_COLOR}Website Configuration${NO_COLOR}\n"

# Run the prompts
prompt_for_website_address
prompt_for_website_port
prompt_for_wordpress_db_name
prompt_for_wordpress_db_username
prompt_for_wordpress_db_password
prompt_for_db_root_password

# Convert the site address periods to underscores
converted_site_address=$(echo "$site_address" | tr . _)

# Create the site directories and files
create_website_directories
create_env_file
create_apache_conf

# Deploy the WordPress site
deploy_website

# Create reports and notices
deployment_user_notice
create_deployment_report