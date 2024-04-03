# Local Development Environment with HTTPS

This project enables secure access to your HTTP applications during development via HTTPS utilizing nginx as a reverse proxy. By offering configurations that support SSL certificate generation with [mkcert](https://github.com/FiloSottile/mkcert) or OpenSSL, it mirrors the HTTPS configurations found in production environments more closely.

Why is this needed ?

In addition to the standard issues (DNS, NAT, Firewalls) surrounding TLS certificates and localhost development. Many cloud native applications are developed without built in HTTPS support as this is often managed by the deployment enviroment, such as Kubernetes or various "server-less" offerings. This often leads to issues where specific conditions have to be written into configurations and application logic in order to handle non HTTPS connection during development.

## Overview

The setup involves nginx configured as a reverse proxy to forward requests to your local development server(s). The locally-trusted SSL certificates can be automatically generated during the Docker build process using mkcert.

### Structure

- `README.md`: Repository Documentation in Markdown format. This file.
- `Dockerfile`: Dockerfile for setting up an HTTPS nginx reverse proxy.
- `Makefile`: Generate the certificates (using mkcert) and build the Docker container.
- `nginx.conf`: The nginx configuration file for the reverse proxy setup. Will need modified for your config.
  
## Getting Started

### Prerequisites

Basic knowledge of [Docker](https://www.docker.com/) and [nginx](https://www.nginx.com/) configurations would be helpful in order to more easily customize this project for use in your local development environments.
  
The following software should be installed on your local development machine:

- [Docker](https://www.docker.com/)
- [mkcert](https://github.com/FiloSottile/mkcert) - For installation options, refer to the [mkcert github repo](https://github.com/FiloSottile/mkcert/).
- [GNU Make](https://www.gnu.org/software/make/)

## Customizing Your Setup

- Modify `nginx.conf` as needed to match your local development setup, especially the `proxy_pass` directive to point to your application's running port. Many applications, such as microservices will require multiple "location" entries in the configuration file.
- Place your `nginx.conf` in the root of your project directory where the Dockerfile resides, so it can be copied into the Docker image.

### Setup Instructions

To set up your local development environment with SSL using this Docker and nginx setup, follow these instructions. The Makefile in the project directory simplifies the process of generating local SSL certificates and building the Docker container image.

1. **Generate SSL Certificates:**

   Use `mkcert` to generate trusted certificates:

   ```bash
   make certs
   ```

   This will create the SSL certificate and key in the certs directory.

2. **Build the Docker Image:**

   After generating the certificates, you can build the Docker image with:

   ```bash
   make build
   ```

3. **Run the Docker Container:**

   After the container image is built, you can run the container in detached mode:

   ```bash
   docker run --name nginx-reverse-proxy -p 80:80 -p 443:443 -d nginx-reverse-proxy
   ```

   This will start the nginx reverse proxy listening on ports 80 (HTTP) and 443 (HTTPS) of your localhost.

4. **Access Your Application:**

   You can now access your application through `https://localhost` in your browser. Note that if you have to accept the self-signed certificate, ensure your browser trusts the mkcert root CA.

## Logging

To monitor the activity and troubleshoot issues within the nginx server, you can check the nginx logs, which are typically located at `/var/log/nginx/`. Since nginx is running in a container, use Docker commands to access these logs. 

### Accessing nginx Logs

To follow all container logs, execute:

```bash
docker logs -f nginx-reverse-proxy
```

To view the nginx access logs, execute:

```bash
docker exec nginx-reverse-proxy cat /var/log/nginx/access.log
```

To check the nginx error logs, use:

```bash
docker exec nginx-reverse-proxy cat /var/log/nginx/error.log
```

You can also follow the log output of specific files in real time by appending the -f flag to the tail command:

```bash
docker exec nginx-reverse-proxy tail -f /var/log/nginx/access.log
```

### Interactive Container Access

For troubleshooting, you might want to access the container directly. You can access an interactive shell in the running nginx container with:

```bash
docker exec -it nginx-reverse-proxy /bin/sh
```

Remember to replace nginx-reverse-proxy with the actual container name if you used a different one.

## Troubleshooting

- **nginx Configuration Issues:** If you encounter errors related to nginx, ensure that your `nginx.conf` is correctly formatted and the paths to your SSL certificates are correct.

- **HSTS Browser Issues:** If you connect to localhost via HTTPS in Chrome and then attempt to connect to localhost via HTTP, the browser will attempt to redirect to HTTPS. You can prevent this from occuring by using the local IP address when connecting via HTTP or delete the localhost entry from the browsers HSTS domains.

   Navigate to [chrome://net-internals/#hsts](chrome://net-internals/#hsts), and enter "localhost" under "Delete domain" and click the "Delete" button.

- **SSL Browser Warnings:** Self-signed certificates will cause browsers to warn about the site's security. You can choose to proceed with an exception or use [mkcert](https://github.com/FiloSottile/mkcert) for generating certificates that will be automatically trusted by your system.
  
## License

This project is open-sourced under the MIT License. See the LICENSE file for more details.