FROM alpine:3.18

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
    haserl \
    busybox-extras \
    lighttpd \
    bash \
    curl \
    coreutils

# Create necessary directories and log files
RUN mkdir -p /var/www/localhost/cgi-bin /var/www/localhost/htdocs /var/log && \
    touch /var/log/lighttpd.log /var/log/cgi-test.log && \
    chmod -R 777 /var/log

# Copy application files
COPY ./app/index.cgi /var/www/localhost/cgi-bin/
COPY ./app/style.css /var/www/localhost/htdocs/
COPY ./app/test.html /var/www/localhost/htdocs/
COPY ./config/lighttpd.conf /etc/lighttpd/lighttpd.conf

# Make CGI script executable and set proper permissions
RUN chmod +x /var/www/localhost/cgi-bin/index.cgi && \
    chmod -R 755 /var/www/localhost/cgi-bin && \
    chmod -R 755 /var/www/localhost/htdocs

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting Haserl app..."' >> /start.sh && \
    echo 'echo "Checking script permissions and content:"' >> /start.sh && \
    echo 'ls -la /var/www/localhost/cgi-bin/' >> /start.sh && \
    echo 'head -1 /var/www/localhost/cgi-bin/index.cgi' >> /start.sh && \
    echo 'echo "Testing CGI script directly (first few lines):"' >> /start.sh && \
    echo 'cd /var/www/localhost/cgi-bin/ && ./index.cgi | head -5' >> /start.sh && \
    echo 'echo "Running lighttpd server..."' >> /start.sh && \
    echo 'lighttpd -D -f /etc/lighttpd/lighttpd.conf 2>&1 | tee -a /var/log/lighttpd.log' >> /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 80

# Run lighttpd server in foreground
CMD ["/start.sh"]