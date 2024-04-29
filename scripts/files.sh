#!/bin/bash
# -----------------------------------------------------------------------------
# Project: Web-Deployment
# File: file.sh
# -----------------------------------------------------------------------------
# Purpose: 
# This file is used to create all the necessary directories and files for the
# web deployment project, during the deployment/migration of a WordPress site.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Create Directories
# -----------------------------------------------------------------------------
function create_website_directories {
    # Define the directory path
    dir_path="$(dirname "$0")/../web-apps/wordpress/$site_address"
    dir_path=$(realpath "$dir_path")

    # Check if the directory already exists
    if [ -d "$dir_path" ]; then
        echo "${NOTICE_COLOR}ERROR${NO_COLOR} - Directory $dir_path already exists"
        exit 1
    fi

    # Create the site directory, the data directory, and the mysql directory
    echo -e "\n${NOTICE_COLOR}Creating${NO_COLOR} $dir_path"
    echo -e "${NOTICE_COLOR}Creating${NO_COLOR} $dir_path/data"
    echo -e "${NOTICE_COLOR}Creating${NO_COLOR} $dir_path/mysql"
    mkdir "$dir_path" "$dir_path/data" "$dir_path/mysql" 2>/dev/null
}

# -----------------------------------------------------------------------------
# Migration Files
# -----------------------------------------------------------------------------
function replace_wp_content {
    # Remove the old wp-content directory
    sudo rm -rf "$dir_path/data/wp-content"
    # Create the new wp-content directory
    sudo mkdir "$dir_path/data/wp-content"
    # Utar the wp-content directory into the new directory
    sudo tar -xvf "$wp_content_tar_gz" -C "$dir_path/data/wp-content"
}

# -----------------------------------------------------------------------------
# .env File
# -----------------------------------------------------------------------------
function create_env_file {
    # Define the .env file path
    env_file="$dir_path/.env"

    # Create the .env file
    echo -e "${NOTICE_COLOR}Creating${NO_COLOR} $env_file\n"
    cat > "$env_file" <<EOF
# -----------------------------------------------------------------------------
# Project: Web-Deployment - $site_address
# File: .env
# -----------------------------------------------------------------------------
# Purpose:
# This file is used to configure the environment variables for the WordPress site.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------


# Database Configuration
MYSQL_DATABASE=$db_name
MYSQL_USER=$db_user
MYSQL_PASSWORD=$db_password
MYSQL_ROOT_PASSWORD=$root_password
MYSQL_VOLUME=$(realpath "$dir_path/mysql")

# WordPress Configuration
WORDPRESS_PORT=$port_number
WORDPRESS_DB_HOST=db-$converted_site_address:3306
WORDPRESS_DB_USER=$db_user
WORDPRESS_DB_PASSWORD=$db_password
WORDPRESS_DB_NAME=$db_name
WORDPRESS_VOLUME=$(realpath "$dir_path/data")
EOF
}

# -----------------------------------------------------------------------------
# Apache configuration (CentOS 8-9 Stream)
# -----------------------------------------------------------------------------
function create_apache_conf {
    # Create a new virtual host configuration file
    site_conf="/etc/httpd/conf.d/10-$converted_site_address.conf"
    # Generate the virtual host configuration file
    cat > "$site_conf" <<EOF
# -----------------------------------------------------------------------------
# Project: Web-Deployment - $site_address
# File: 10-$converted_site_address.conf
# -----------------------------------------------------------------------------
# Purpose:
# This file is used to configure the virtual host for the $site_address site.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

<VirtualHost *:443>
    ServerName $site_address:443
    ServerAlias $site_address

    ProxyPass / http://127.0.0.1:$port_number/
    ProxyPassReverse / http://127.0.0.1:$port_number/

    <Location />
        ProxyPassReverse /
        ProxyPassReverseCookiePath / /
        Order allow,deny
        Allow from all
    </Location>

    ErrorLog logs/ssl_error_log
    TransferLog logs/ssl_access_log
    LogLevel warn
    CustomLog logs/ssl_request_log "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

    SSLEngine on
    SSLProtocol -all +TLSv1.2
    SSLProxyProtocol -all +TLSv1.2
    SSLHonorCipherOrder on
#    SSLCertificateFile /path/to/your/certificate.crt
#    SSLCertificateKeyFile /path/to/your/private.key
#    SSLCertificateChainFile /path/to/your/chainfile.pem

    BrowserMatch "MSIE [2-5]" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
        </FilesMatch>
    <Directory "/var/www/cgi-bin">
        SSLOptions +StdEnvVars
    </Directory>

</VirtualHost>
EOF
}

# -----------------------------------------------------------------------------
# Report Files
# -----------------------------------------------------------------------------
function create_deployment_report {
    # Create a repot file
    report_file="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )/reports/$site_address"

    # Create the report file
    cat > "$report_file" <<EOF
# -----------------------------------------------------------------------------
# Project: Web-Deployment - $site_address
# File: $site_address
# -----------------------------------------------------------------------------
# Purpose:
# This file is a general report for the deployment of the $site_address site.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

Deployment Date: $timestamp
Deployment User: $(whoami)
Deployment Host: $(hostname)
Deployment Directory: $dir_path
Deployment Port: $port_number
HTTPD Configuration File: $site_conf
EOF
}

function create_migration_report {
    # Create a repot file
    report_file="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )/reports/$site_address"

    # Create the report file
    cat > "$report_file" <<EOF
# -----------------------------------------------------------------------------
# Project: Web-Deployment - $site_address
# File: $site_address
# -----------------------------------------------------------------------------
# Purpose:
# This file is a general report for the migration of the $site_address site.
#
# Copyright (C) 2024 CARS, The University of Chicago, USA
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

Migration Date: $timestamp
Deployment User: $(whoami)
Deployment Host: $(hostname)
Deployment Directory: $dir_path
Deployment Port: $port_number
Migration Dump: $db_dump_sql
Migration WP-Content: $wp_content_tar_gz
HTTPD Configuration File: $site_conf
EOF
}