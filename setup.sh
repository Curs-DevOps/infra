#!/bin/bash

echo "=================================="
echo "Docker Registry Setup"
echo "=================================="
echo ""

# Prompt for username and password
read -p "Enter username (default: admin): " USERNAME
USERNAME=${USERNAME:-admin}

read -sp "Enter password (default: admin): " PASSWORD
echo ""
PASSWORD=${PASSWORD:-admin}

echo ""
echo "Setting up registry with credentials:"
echo "Username: $USERNAME"
echo "Password: ********"
echo ""

# Create auth directory
mkdir -p ./auth

# Generate htpasswd file
echo "Creating password file..."
if command -v htpasswd &> /dev/null; then
    # Use local htpasswd if available
    htpasswd -Bbn "$USERNAME" "$PASSWORD" > ./auth/htpasswd
elif command -v podman &> /dev/null; then
    # Use podman
    podman run --rm --entrypoint htpasswd httpd:2 -Bbn "$USERNAME" "$PASSWORD" > ./auth/htpasswd
elif command -v docker &> /dev/null; then
    # Use docker
    docker run --rm --entrypoint htpasswd httpd:2 -Bbn "$USERNAME" "$PASSWORD" > ./auth/htpasswd
else
    echo "Error: Neither htpasswd, docker, nor podman found!"
    exit 1
fi

# Create credentials file for reference
cat > credentials.txt << EOF
Registry Credentials
====================
Username: $USERNAME
Password: $PASSWORD

Registry URL: localhost:6081
UI URL: http://localhost:6080

To login:
  ./login.sh

Or manually:
  podman login localhost:6081
  Username: $USERNAME
  Password: $PASSWORD
EOF

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Your credentials are saved in 'credentials.txt'"
echo ""
echo "To start the registry:"
echo "  podman-compose up -d"
echo ""
echo "To login:"
echo "  ./login.sh"
echo ""
echo "Access the UI at: http://localhost:6080"
echo ""
