#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Haserl Docker Log Viewer ===${NC}"
echo ""

# Check if the container is running
if ! docker ps | grep -q "haserl-app"; then
    echo -e "${RED}Error: haserl-app container is not running!${NC}"
    echo "Start the container with: docker-compose up -d"
    exit 1
fi

# Function to view logs
view_logs() {
    local log_type=$1
    local lines=${2:-50}
    
    case "$log_type" in
        all)
            echo -e "${GREEN}=== All Container Logs (last $lines lines) ===${NC}"
            docker logs --tail "$lines" haserl-app
            ;;
        lighttpd)
            echo -e "${GREEN}=== Lighttpd Access Logs (last $lines lines) ===${NC}"
            docker exec -it haserl-app cat /var/log/lighttpd.log | tail -n "$lines"
            ;;
        error)
            echo -e "${GREEN}=== Lighttpd Error Logs (last $lines lines) ===${NC}"
            docker exec -it haserl-app cat /var/log/lighttpd.error.log | tail -n "$lines"
            ;;
        cgi)
            echo -e "${GREEN}=== CGI Test Output ===${NC}"
            docker exec -it haserl-app cat /var/log/cgi-test.log
            ;;
        *)
            echo -e "${RED}Unknown log type: $log_type${NC}"
            echo "Available log types: all, lighttpd, error, cgi"
            exit 1
            ;;
    esac
}

# Function to show a menu
show_menu() {
    echo -e "${YELLOW}Select the logs you want to view:${NC}"
    echo "1) All container logs"
    echo "2) Lighttpd access logs"
    echo "3) Lighttpd error logs"
    echo "4) CGI test output"
    echo "5) Live log viewer (follow)"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
    
    case "$choice" in
        1) view_logs all ;;
        2) view_logs lighttpd ;;
        3) view_logs error ;;
        4) view_logs cgi ;;
        5) 
            echo -e "${GREEN}=== Live Log Viewer (Ctrl+C to exit) ===${NC}"
            docker logs -f haserl-app
            ;;
        6) exit 0 ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            show_menu
            ;;
    esac
}

# If arguments are provided, use those
if [ $# -gt 0 ]; then
    view_logs "$@"
else
    # Otherwise show the menu
    show_menu
fi