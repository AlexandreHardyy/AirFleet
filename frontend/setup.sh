#!/bin/bash

# Set up Flutter environment
export PATH="$PATH:$(pwd)/flutter/bin"
echo "PUBLIC_ACCESS_TOKEN_MAPBOX=$PUBLIC_ACCESS_TOKEN_MAPBOX" >> .env
echo "API_URL=$API_URL" >> .env
echo "API_URL_ANDROID=$API_URL_ANDROID" >> .env
echo "SOCKET_IO_URL=$SOCKET_IO_URL" >> .env
echo "SOCKET_IO_URL_ANDROID=$SOCKET_IO_URL_ANDROID" >> .env
echo "PUBLIC_API_KEY_STRIPE=$PUBLIC_API_KEY_STRIPE" >> .env

# Build the Flutter web app
flutter doctor
flutter pub get
flutter build web --release --web-renderer html --output build/web