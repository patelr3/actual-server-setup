#!/bin/bash -e

DATA_DIR=$(realpath ./actual-data)
mkdir -p $DATA_DIR

# Need to setup self-signed certs first to configure https
# (This allows any computer on the network to connect to host)
# https://actualbudget.org/docs/config/https/
CONTAINER_CERT_DIR=/data/cert-files
CERT_DIR=$DATA_DIR/cert-files
KEY_NAME=actual-server.key
CERT_NAME=actual-server.crt

mkdir -p $CERT_DIR
KEY_PATH=$CERT_DIR/$KEY_NAME
CERT_PATH=$CERT_DIR/$CERT_NAME
CONFIG_PATH=$DATA_DIR/config.json
if [ ! -f $CERT_PATH ]; then
    echo "Creating self-signed certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $KEY_PATH -out $CERT_PATH
    echo "Certificates created!"

    echo "Creating $CONFIG_PATH file for actual-server"
    cat <<EOF > $CONFIG_PATH
{
    "https": {
        "key": "$CONTAINER_CERT_DIR/$KEY_NAME",
        "cert": "$CONTAINER_CERT_DIR/$CERT_NAME"
    }
}
EOF
    echo "$CONFIG_PATH created with paths to the certificates."
fi

# Now setup/update server
# https://actualbudget.org/docs/install/docker/
echo "Setting up actual-server..."

# Path to docker-compose file
ACTUAL_SERVER_DOCKER_COMPOSE_PATH=./actual-server/docker-compose.yml
DOCKER_COMPOSE_SYMLINK_PATH=./docker-compose.yml

# Check if we've created a symlink yet
if [ -L $DOCKER_COMPOSE_SYMLINK_PATH ]; then
    echo "docker-compose.yml symlink already exists."
else
    ln -s $ACTUAL_SERVER_DOCKER_COMPOSE_PATH $DOCKER_COMPOSE_SYMLINK_PATH
    echo "docker-compose.yml symlink created."
fi

# Start docker
if docker-compose ps | grep -q actual_server; then
    echo "actual_server service is running. Updating..."
    docker-compose down && docker-compose pull && docker-compose up -d
else
    echo "actual_server service is not running. Starting..."
    docker-compose up --detach
fi
echo "Actual Budget started on port https://localhost:5006!"
