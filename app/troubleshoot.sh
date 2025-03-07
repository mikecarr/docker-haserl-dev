#!/bin/bash

echo "=== Haserl Troubleshooting Script ==="
echo ""

# Check if haserl is installed
echo "1. Checking if haserl is installed..."
if command -v haserl &> /dev/null; then
    HASERL_PATH=$(which haserl)
    echo "   ✓ Haserl found at: $HASERL_PATH"
    echo "   ✓ Haserl version: $(haserl --version 2>&1 | head -1)"
else
    echo "   ✗ Haserl not found in PATH. You may need to install it:"
    echo "     Alpine: apk add haserl"
    echo "     Debian/Ubuntu: apt-get install haserl"
    echo "     CentOS/RHEL: yum install haserl"
fi
echo ""

# Check file permissions
echo "2. Checking file permissions..."
if [ -f "./app/index.cgi" ]; then
    PERMS=$(stat -c "%a" ./app/index.cgi 2>/dev/null || stat -f "%Lp" ./app/index.cgi 2>/dev/null || echo "unknown")
    echo "   ✓ index.cgi exists with permissions: $PERMS"
    if [ "$PERMS" != "755" ] && [ "$PERMS" != "775" ] && [ "$PERMS" != "777" ]; then
        echo "     ⚠️  Permissions should be 755 for execution. Running: chmod 755 ./app/index.cgi"
        chmod 755 ./app/index.cgi
    fi
else
    echo "   ✗ ./app/index.cgi file not found in current path"
    
    # Try to find it
    FOUND_FILES=$(find . -name "index.cgi" 2>/dev/null)
    if [ -n "$FOUND_FILES" ]; then
        echo "     Found these index.cgi files instead:"
        echo "$FOUND_FILES" | while read file; do
            PERMS=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null || echo "unknown")
            echo "     - $file (permissions: $PERMS)"
            echo "       Setting executable permissions: chmod 755 \"$file\""
            chmod 755 "$file"
        done
    else
        echo "     No index.cgi files found in the current directory or subdirectories"
    fi
fi
echo ""

# Check file line endings
echo "3. Checking file line endings..."
if command -v file &> /dev/null && [ -f "./app/index.cgi" ]; then
    FILE_TYPE=$(file ./app/index.cgi)
    echo "   File type: $FILE_TYPE"
    if [[ "$FILE_TYPE" == *"CRLF"* ]]; then
        echo "   ⚠️  File has Windows line endings (CRLF). This might cause issues."
        echo "   Converting to Unix line endings (LF)..."
        if command -v dos2unix &> /dev/null; then
            dos2unix ./app/index.cgi
            echo "   ✓ Converted using dos2unix"
        else
            if command -v sed &> /dev/null; then
                sed -i 's/\r$//' ./app/index.cgi
                echo "   ✓ Converted using sed"
            else
                echo "   ✗ Could not convert: neither dos2unix nor sed found"
            fi
        fi
    else
        echo "   ✓ File has correct line endings"
    fi
else
    echo "   ⚠️  Could not check line endings: 'file' command not available or file not found"
fi
echo ""

# Check Docker
echo "4. Checking Docker environment..."
if command -v docker &> /dev/null; then
    echo "   ✓ Docker is installed"
    
    if command -v docker-compose &> /dev/null; then
        echo "   ✓ Docker Compose is installed"
    else
        echo "   ⚠️  Docker Compose not found"
    fi
    
    # Check if container is running
    if docker ps | grep -q "haserl-app"; then
        echo "   ✓ haserl-app container is running"
        
        # Check logs for errors
        echo ""
        echo "   Last 10 log entries from container:"
        docker logs --tail 10 haserl-app
    else
        echo "   ✗ haserl-app container is not running"
    fi
else
    echo "   ✗ Docker not found in PATH"
fi
echo ""

# Try to run the script directly
echo "5. Trying to run index.cgi directly..."
if [ -f "./app/index.cgi" ]; then
    echo "   Attempting to execute the script..."
    (cd ./app && ./index.cgi) > /tmp/haserl_test.html 2>/tmp/haserl_test.error
    
    if [ -s /tmp/haserl_test.error ]; then
        echo "   ✗ Error output detected:"
        cat /tmp/haserl_test.error
    else
        echo "   ✓ Script executed without error output"
    fi
    
    if [ -s /tmp/haserl_test.html ]; then
        HTML_SIZE=$(stat -c "%s" /tmp/haserl_test.html 2>/dev/null || stat -f "%z" /tmp/haserl_test.html 2>/dev/null)
        echo "   ✓ Output generated ($HTML_SIZE bytes)"
        
        if grep -q "<!DOCTYPE html>" /tmp/haserl_test.html; then
            echo "   ✓ Output appears to be valid HTML"
        else
            echo "   ⚠️  Output doesn't look like valid HTML. First 5 lines:"
            head -5 /tmp/haserl_test.html
        fi
    else
        echo "   ✗ No output generated"
    fi
else
    echo "   ✗ Cannot run index.cgi: file not found"
fi
echo ""

echo "=== Troubleshooting Complete ==="
echo ""
echo "Next steps:"
echo "1. Ensure haserl is installed correctly"
echo "2. Make sure index.cgi has execute permissions (chmod 755)"
echo "3. Check for proper Unix line endings (LF, not CRLF)"
echo "4. Try rebuilding the Docker container:"
echo "   docker-compose down"
echo "   docker-compose build"
echo "   docker-compose up -d"
echo ""
echo "If problems persist, check the Docker logs:"
echo "docker-compose logs haserl-app"