#!/bin/bash

# File path to the script itself
SCRIPT_PATH=$(realpath "$0")
RESTART_FLAG=0  # A flag to check if a restart is needed

# Function for monitoring the website
monitor_webserver() {
    # Check the website
    if ! curl -s "http://nano.fqp.ch:8888/" > /dev/null; then
        echo "$(date) - Connection failed. Restarting viseron container." >> ./viseron_monitor.log
        RESTART_FLAG=1
    fi
}

# Function for monitoring the logs
monitor_camera_dead() {
    # Get the last line from the Docker logs for the viseron container
    local last_log=$(docker logs viseron 2>&1 | tail -n 1)

    # Desired string to match
    local match_str="Thread viseron.camera.camera_1 is dead, restarting"
    
    # Check if the last_log matches the desired string
    if [[ "$last_log" == *"$match_str"* ]]; then
        echo "$(date) - Thread viseron.camera.camera_1 is dead, restarting viseron container..." >> ./viseron_monitor.log
        RESTART_FLAG=1
    fi
}

# Function for installing the cron job
install_cron() {
    CRON_CMD="*/2 * * * * $SCRIPT_PATH"

    # Add to cron if not already added
    (crontab -l | grep -v -F "$SCRIPT_PATH"; echo "$CRON_CMD" ) | crontab -
    echo "Cron job installed to run every 2 minutes."
}

# Function for removing the cron job
remove_cron() {
    # Remove the specific cron job related to this script
    crontab -l | grep -v -F "$SCRIPT_PATH" | crontab -
    echo "Cron job removed."
}

# Check command-line arguments
if [ "$1" = "install" ]; then
    install_cron
elif [ "$1" = "remove" ]; then
    remove_cron
else
    monitor_webserver
    monitor_camera_dead
    if [ "$RESTART_FLAG" -eq 1 ]; then
        docker restart viseron
    fi
fi
