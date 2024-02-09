#!/bin/bash
# -----------------------------------------------------------------------------
# Project: Web-Deployment
# File: prompts.sh
# -----------------------------------------------------------------------------
# Purpose: 
# This file is used to define the prompts for the web deployment project.
#
# Copyright (C) 2024 GSECARS, The University of Chicago, USA
# This project is distributed under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Website Address and Port
# -----------------------------------------------------------------------------
function prompt_for_website_address {
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
}

function prompt_for_website_port {
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
}

# -----------------------------------------------------------------------------
# WordPress Configuration
# -----------------------------------------------------------------------------
function prompt_for_wordpress_db_name {
    # Get the WordPress database name
    while true; do
        # Prompt the user for the WordPress database name
        read -rp "Enter the WordPress database name: " db_name

        # Check if the database name is empty or contains invalid characters
        if [ -z "$db_name" ] || [[ ! "$db_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo "Invalid database name. Database name must not be empty and can only contain alphanumeric characters, hyphens, and underscores"
        else
            break
        fi
    done
}

function prompt_for_wordpress_db_username {
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
}

function prompt_for_wordpress_db_password {
    # Get the WordPress database password
    while true; do
        # Prompt the user for the WordPress database password
        read -rsp "Enter the WordPress database password: " db_password
        echo

        # Prompt the user to re-enter the WordPress database password
        read -rsp "Re-enter the WordPress database password: " db_password_confirm
        echo

        # Check if the database password is empty or contains $ characters
        if [ -z "$db_password" ] || [[ "$db_password" =~ \$ ]]; then
            echo "Invalid database password. Database password must not be empty and cannot contain the \$ character"
            continue
        fi

        # Check if the passwords match
        if [ "$db_password" != "$db_password_confirm" ]; then
            echo "ERROR - Passwords do not match"
            continue
        fi

        break
    done
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------
function prompt_for_db_root_password {
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

        # Check if the database root password is empty or contains $ characters
        if [ -z "$root_password" ] || [[ "$root_password" =~ \$ ]]; then
            echo "Invalid database root password. Database root password must not be empty and cannot contain the \$ character"
            continue
        fi

        # Check if the passwords match
        if [ "$root_password" != "$root_password_confirm" ]; then
            echo "ERROR - Passwords do not match"
            continue
        fi

        break
    done
}
