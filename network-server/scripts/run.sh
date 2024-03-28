#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

# This script have to be duplicated in all the services, because Docker doesn't support
# copying files into container from outside the current working directory.

SERVICE=chirpstack

# Update config based on add-on config
/scripts/update_config.sh

# Start the Chirpstack service
bashio::log.info "Starting $SERVICE..."
systemctl start $SERVICE

# Keep container running
tail -F /var/log/$SERVICE/$SERVICE.log
