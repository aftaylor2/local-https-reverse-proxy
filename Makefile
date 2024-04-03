# Makefile to generate SSL certificates and build Docker image

# Variables
CERT_DIR=./certs
NGINX_CONF=./nginx.conf

# Default target
all: build

# Optional targets for certificate generation
.PHONY: certs-mkcert
certs-mkcert:
	mkcert -install
	mkcert -cert-file $(CERT_DIR)/localhost.crt -key-file $(CERT_DIR)/localhost.key localhost 127.0.0.1 ::1

.PHONY: certs-openssl
certs-openssl:
	mkdir -p $(CERT_DIR)
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout $(CERT_DIR)/localhost.key -out $(CERT_DIR)/localhost.crt \
		-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost"

# Build Docker image
.PHONY: build
build: certs
	docker build -t nginx-reverse-proxy .

# Clean up certificates
.PHONY: clean
clean:
	rm -rf $(CERT_DIR)/*.crt $(CERT_DIR)/*.key

# Uninstall - remove the certs from the trust store
.PHONY: uninstall
uninstall:
	mkcert -uninstall
	make clean

# Backward compatibility with previous versions of this Makefile
.PHONY: certs
certs: certs-mkcert
