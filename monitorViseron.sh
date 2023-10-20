#!/bin/bash

# File path to the script itself
SCRIPT_PATH=$(realpath "$0")

# Function for monitoring
monitor_docker() {
    # Check the website
    if ! curl -s "http://nano.fqp.ch:8888/" > /dev/null; then
        echo "$(date) - Connection failed. Restarting 'viseron' container." >> ./viseron_monitor.log
        docker restart viseron
    fi
}

# Function for installing the cron job
install_cron() {
    CRON_CMD="*/2 * * * * $SCRIPT_PATH"

    # Add to cron if not already added
    (crontab -l | grep -v -F "$SCRIPT_PATH"; echo "$CRON_CMD" ) | crontab -
    echo "Cron job installed to run every 2 minutes."
}

# Check command-line arguments
if [ "$1" = "install" ]; then
    install_cron
else
    monitor_docker
fi
