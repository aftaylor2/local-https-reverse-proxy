# Use an image that has curl and ca-certificates
FROM nginx:alpine

LABEL name="local-https-reverse-proxy" \
  version="1.0.0" \
  org.opencontainers.image.title="local-https-reverse-proxy" \
  org.opencontainers.image.description="Ensure your dev environment supports HTTPS." \
  org.opencontainers.image.version="1.0.0" \
  org.opencontainers.image.documentation="https://github.com/aftaylor2/local-https-reverse-proxy/blob/master/README.md" \
  org.opencontainers.image.source="https://github.com/aftaylor2/local-https-reverse-proxy" \
  org.opencontainers.image.authors="Andrew Taylor <aftaylor2@gmail.com>" \
  org.opencontainers.image.licenses="MIT"

# Remove the default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Create the directory for SSL certificates
WORKDIR /etc/nginx/ssl

# Copy locally generated SSL certificates
COPY certs/localhost.crt /etc/nginx/ssl/
COPY certs/localhost.key /etc/nginx/ssl/

# Expose ports for HTTP and HTTPS
EXPOSE 80 443

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
