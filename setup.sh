#!/bin/bash

# Create directories if they don't exist
mkdir -p app config

# Make sure the CGI script is executable
chmod +x app/index.cgi

echo "Setting up Haserl Docker application..."
echo "Directory structure created."
echo ""
echo "To start the application, run:"
echo "docker-compose up -d"
echo ""
echo "Then access the application at:"
echo "http://localhost:8080"
