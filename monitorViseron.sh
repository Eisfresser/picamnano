#!/bin/bash

# File path to the script itself
SCRIPT_PATH=$(realpath "$0")

# Function for monitoring the website
monitor_docker() {
    # Check the website
    if ! curl -s "http://nano.fqp.ch:8888/" > /dev/null; then
        echo "$(date) - Connection failed. Restarting viseron container." >> ./viseron_monitor.log
        docker restart viseron
    fi
}

# Function for monitoring the logs
function check_and_restart_viseron() {
    # Get the last line from the Docker logs for the viseron container
    local last_log=$(docker logs viseron 2>&1 | tail -n 1)

    # Desired string to match
    local match_str="[viseron.watchdog.thread_watchdog] - Thread viseron.camera.camera_1 is dead, restarting"

    # Check if the last_log matches the desired string
    if [[ "$last_log" == *"$match_str"* ]]; then
        echo "Thread viseron.camera.camera_1 is dead, restarting viseron container..." >> ./viseron_monitor.log
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
