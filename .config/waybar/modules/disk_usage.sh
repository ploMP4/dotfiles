#!/bin/bash

# Adjust the mount point as needed, e.g., / or /home
mount_point="/"
used=$(df -h "$mount_point" | awk 'NR==2 {print $3}')
total=$(df -h "$mount_point" | awk 'NR==2 {print $2}')
percent=$(df -h "$mount_point" | awk 'NR==2 {print $5}')

echo -e "{\"text\": \"$used / $total ($percent)\", \"class\": \"disk\"}"
