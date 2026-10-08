#!/bin/bash

# Function to display usage help
usage() {
  echo "Usage: $0 <registry/image-name> -f <Dockerfile-path>"
  exit 1
}

# Check if the correct number of arguments is passed
if [ "$#" -ne 3 ]; then
  echo "Error: Incorrect number of arguments. Expected 3, got $#."
  usage
fi

# Assign positional arguments
TAG="$1"
DOCKERFILE_FLAG="$2"
DOCKERFILE_PATH="$3"

HOST=$(echo "$TAG" | cut -d'/' -f1)
NAME=$(echo "$TAG" | cut -d'/' -f2 | cut -d':' -f1)
VERSION=$(echo "$TAG" | cut -d'/' -f2| cut -d':' -f2)

if [ ! -z "$HOST" ]; then
  NAME="$HOST/$NAME"
fi

# Check if the -f flag is used correctly
if [ "$DOCKERFILE_FLAG" != "-f" ]; then
  usage
fi

# Check if the Dockerfile exists
if [ ! -f "$DOCKERFILE_PATH" ]; then
  echo "Error: Dockerfile '$DOCKERFILE_PATH' does not exist."
  exit 1
fi

# Extract named stages from the Dockerfile
STAGES=$(grep -oP '(?<= as ).*(?=$)' "$DOCKERFILE_PATH")

# Check if there are named stages
if [ -z "$STAGES" ]; then
  echo "Error: No named stages found in the Dockerfile."
  exit 1
fi


echo "This would build the following images:"
# Build each stage
for STAGE in $STAGES; do
  echo "$NAME.$STAGE  :  $VERSION"
done

echo "Do you want to continue? (y/n)"

read -r CONTINUE

if [ "$CONTINUE" != "y" ]; then
 echo "Exiting..."
  exit 1
fi

# Build each stage
for STAGE in $STAGES; do
  podman build --target "$STAGE" -t "$NAME.$STAGE:$VERSION" -f "$DOCKERFILE_PATH" .
done


echo "All stages have been built successfully."
