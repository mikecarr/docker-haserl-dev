#!/bin/sh

# Create logs directory if it doesn't exist
mkdir -p logs

# Set proper permissions
chmod 777 logs

echo "Logs directory created at ./logs"
echo "This directory will be mounted to /var/log inside the container"
echo "You can view logs directly from this directory"