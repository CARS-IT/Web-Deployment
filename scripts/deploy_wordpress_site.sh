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

# Define colors
NOTICE_COLOR="\033[0;31m"
SEPERATOR_COLOR="\033[0;33m"
SUCCESS_COLOR="\033[0;32m"
NO_COLOR="\033[0m"

# Current timestamp
timestamp=$(date +"%Y-%m-%d %T")

echo -e "\n${SEPERATOR_COLOR}Website Configuration${NO_COLOR}\n"
# -----------------------------------------------------------------------------
# Section: Website Address and Port
# -----------------------------------------------------------------------------
# Get the address of the site
while true; do
    # Prompt the user for the address of the site
    read -rp "Enter the address of the site: " site_address

    # Check if the site address is empty or contains invalid characters
    if [ -z "$site_address" ] || [[ ! "$site_address" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid site address. Site address must not be empty and can only contain alphanumeric characters, hyphens, underscores and periods"
    else
        break
    fi
done

# Get the port number for the WordPress site
while true; do
    # Prompt the user for the port number
    read -rp "Enter the port number for the WordPress site: " port_number

    # Check if the port number is empty or contains invalid characters
    if [ -z "$port_number" ] || [[ ! "$port_number" =~ ^[0-9]+$ ]]; then
        echo "Invalid port number. Port number must not be empty and can only contain numeric characters"
    else
        break
    fi
done

# -----------------------------------------------------------------------------
# Section: WordPress Configuration
# -----------------------------------------------------------------------------
# Get the WordPress database username
while true; do
    read -rp "Enter the WordPress database user: " db_user

    # Check if the database user is empty or contains invalid characters
    if [ -z "$db_user" ] || [[ ! "$db_user" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid database user. Database user must not be empty and can only contain alphanumeric characters, hyphens, and underscores"
    else
        break
    fi
done

# Get the WordPress database password
while true; do
    # Prompt the user for the WordPress database password
    read -rsp "Enter the WordPress database password: " db_password
    echo

    # Prompt the user to re-enter the WordPress database password
    read -rsp "Re-enter the WordPress database password: " db_password_confirm
    echo

    # Check if the database password is empty
    if [ -z "$db_password" ]; then
        echo "Invalid database password. Database password must not be empty"
        continue
    fi

    # Check if the passwords match
    if [ "$db_password" != "$db_password_confirm" ]; then
        echo "ERROR - Passwords do not match"
        continue
    fi

    break
done

# -----------------------------------------------------------------------------
# Section: Database Configuration
# -----------------------------------------------------------------------------
# Get the database root password
while true; do
    # Create a random password
    root_password=$(openssl rand -base64 32)

    # Prompt the user for random password confirmation
    read -rp "Do you want to use the following random password for the database root user? (Y/n): $root_password " random_password_confirm

    if [ -z "$random_password_confirm" ]; then
        random_password_confirm="y"
    fi

    case $random_password_confirm in
        [yY][eE][sS]|[yY])
            random_password_confirm="y"
            break
            ;;
    esac

    # Prompt the user for the database root password
    read -rsp "Enter the database root password: " root_password
    echo

    # Prompt the user to re-enter the database root password
    read -rsp "Re-enter the database root password: " root_password_confirm
    echo

    # Check if the database root password is empty
    if [ -z "$root_password" ]; then
        echo "Invalid database root password. Database root password must not be empty"
        continue
    fi

    # Check if the passwords match
    if [ "$root_password" != "$root_password_confirm" ]; then
        echo "ERROR - Passwords do not match"
        continue
    fi

    break
done

# -----------------------------------------------------------------------------
# Section: Create Directories
# -----------------------------------------------------------------------------
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

# Convert the site address periods to underscores
converted_site_address=$(echo "$site_address" | tr . _)

# -----------------------------------------------------------------------------
# Section: Create .env File
# -----------------------------------------------------------------------------
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
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------


# Database Configuration
MYSQL_DATABASE=wordpress-$converted_site_address
MYSQL_USER=$db_user
MYSQL_PASSWORD=$db_password
MYSQL_ROOT_PASSWORD=$root_password
MYSQL_VOLUME=$(realpath "$dir_path/mysql")

# WordPress Configuration
WORDPRESS_PORT=$port_number
WORDPRESS_DB_HOST=db-$converted_site_address:3306
WORDPRESS_DB_USER=$db_user
WORDPRESS_DB_PASSWORD=$db_password
WORDPRESS_DB_NAME=wordpress-$converted_site_address
WORDPRESS_VOLUME=$(realpath "$dir_path/data")
EOF

# -----------------------------------------------------------------------------
# Section: Docker Compose Configuration
# -----------------------------------------------------------------------------
# Copy the docker-compose-template.yaml file to the site root directory
cp "$(dirname "$0")/../templates/docker-compose-template.yaml" "$dir_path/docker-compose.yaml"

# Replace the placeholders in the docker-compose.yaml file
sed -i "s|db_site_name|db-$converted_site_address|g" "$dir_path/docker-compose.yaml"
sed -i "s|wordpress_site_name|wp-$converted_site_address|g" "$dir_path/docker-compose.yaml"

# Deploy the WordPress site
docker compose -f "$dir_path/docker-compose.yaml" up -d
# -----------------------------------------------------------------------------
# Apache configuration (CentOS 8-9 Stream)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Section: Inform the User
# -----------------------------------------------------------------------------
# Inform the user that the site has been successfully deployed
echo "\nSite $site_address has been successfully deployed"

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