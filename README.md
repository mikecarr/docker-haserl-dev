# Dockerized Haserl Web Application

This project demonstrates a simple Haserl web application running inside Docker with Lighttpd as the web server. Haserl is a small CGI wrapper that allows you to embed shell scripts within HTML documents.

## Features

- Lightweight Haserl application running on Alpine Linux
- Lighttpd web server for high performance
- Docker and Docker Compose configuration for easy deployment
- Simple web interface with dynamic content
- Form processing capability
- Environment variable display
- Server information display

## Prerequisites

- Docker
- Docker Compose

## Project Structure

```
.
├── app
│   ├── index.cgi    # Main Haserl application script
│   └── style.css    # CSS styling for the application
├── config
│   └── lighttpd.conf # Lighttpd web server configuration
├── Dockerfile       # Docker image definition
├── docker-compose.yml # Docker Compose configuration
└── README.md        # This documentation file
```

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/haserl-docker.git
   cd haserl-docker
   ```

2. Create the required directory structure:
   ```bash
   mkdir -p app config
   ```

3. Copy all the files from this repository into the appropriate directories.

4. Make the CGI script executable:
   ```bash
   chmod +x app/index.cgi
   ```

5. Start the application with Docker Compose:
   ```bash
   docker-compose up -d
   ```

6. Access the application in your web browser at:
   ```
   http://localhost:8080
   ```

## Customizing the Application

### Modifying the Haserl Script

The main application logic is in `app/index.cgi`. You can edit this file to add more functionality or change the existing features. Remember that it's a Haserl script, which means you can mix HTML and shell script code.

### Styling

The application's appearance is controlled by `app/style.css`. Modify this file to change the look and feel of your application.

### Web Server Configuration

The Lighttpd web server configuration is in `config/lighttpd.conf`. You can adjust server settings, add virtual hosts, or configure additional modules here.

## Docker Configuration

### Dockerfile

The Dockerfile uses Alpine Linux as the base image and installs the necessary packages for running Haserl and Lighttpd. It also sets up the directory structure and permissions.

### Docker Compose

The `docker-compose.yml` file configures the service, networking, and port mapping. By default, the application is accessible on port 8080 of your host machine.

## Advanced Usage

### Environment Variables

You can add environment variables to the Docker Compose file to configure your application:

```yaml
services:
  haserl-app:
    # ...
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - CUSTOM_VARIABLE=value
```

These variables will be available to your Haserl script.

### Persistent Storage

If you need to store data persistently, you can add volumes to the Docker Compose file:

```yaml
services:
  haserl-app:
    # ...
    volumes:
      - ./app:/var/www/localhost/cgi-bin
      - ./data:/var/data
```

### Adding Additional Services

You can extend your application by adding more services to the Docker Compose file, such as a database:

```yaml
services:
  haserl-app:
    # ...
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=mysecretpassword
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### Troubleshooting

### Common Issues

1. **"Exception" error when running scripts directly**:
   - If you get only "Exception" when running Haserl scripts, check:
   - Shebang line: Make sure it's `#!/usr/bin/haserl` (not `/usr/bin/env haserl`)
   - File permissions: Run `chmod +x app/index.cgi`
   - Line endings: Convert from CRLF to LF with `dos2unix app/index.cgi`
   - Test with a minimal script first to isolate the issue

2. **403 Forbidden errors**:
   - Check directory and file permissions in the container
   - Ensure Lighttpd can access the CGI directory
   - Verify the Lighttpd configuration has proper aliases set

3. **500 Internal Server Error**:
   - Check the logs: `docker-compose logs haserl-app` or look in the `./logs` directory
   - Run the script directly to check for syntax errors: `docker exec -it haserl-app /var/www/localhost/cgi-bin/index.cgi`
   - Verify the CGI script has the correct shebang line and is executable

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Haserl](http://haserl.sourceforge.net/) - The CGI scripting tool
- [Lighttpd](https://www.lighttpd.net/) - The web server
- [Alpine Linux](https://alpinelinux.org/) - The base operating system for the Docker image