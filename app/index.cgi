#!/usr/bin/haserl
<%
# Set content type
echo "Content-type: text/html"
echo ""

# Get current date and time
current_date=$(date)

# Get server info - simplified with error handling
hostname=$(hostname 2>/dev/null || echo "Unknown")
kernel=$(uname -r 2>/dev/null || echo "Unknown")
uptime=$(uptime 2>/dev/null || echo "Unknown")
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Haserl Docker Demo</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to Haserl in Docker!</h1>
        
        <div class="info-box">
            <h2>Server Information</h2>
            <p><strong>Date and Time:</strong> <%= $current_date %></p>
            <p><strong>Hostname:</strong> <%= $hostname %></p>
            <p><strong>Kernel:</strong> <%= $kernel %></p>
            <p><strong>Uptime:</strong> <%= $uptime %></p>
        </div>

        <div class="form-container">
            <h2>Enter Your Name</h2>
            <% if [ -n "$FORM_name" ]; then %>
                <div class="greeting">
                    <p>Hello, <%= $FORM_name %>! Nice to meet you.</p>
                </div>
            <% fi %>
            
            <form method="POST">
                <div class="form-group">
                    <label for="name">Your Name:</label>
                    <input type="text" id="name" name="name" value="<%= $FORM_name %>">
                </div>
                <button type="submit">Submit</button>
            </form>
        </div>

        <div class="env-variables">
            <h2>Environment Variables</h2>
            <pre>
<% env 2>/dev/null | sort 2>/dev/null || echo "Could not retrieve environment variables" %>
            </pre>
        </div>
    </div>
</body>
</html>