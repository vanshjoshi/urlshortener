#!/bin/bash

echo "Starting deployment..."

# Go to parent directory
cd /home/ec2-user || exit

echo "Cleaning old application..."
rm -rf urlshortener/*

# Now go into fresh copied files
cd /home/ec2-user/urlshortener || exit

echo "Installing dependencies..."
npm install

echo "Starting application..."

# Ensure pm2 exists
which pm2 || sudo npm install -g pm2

pm2 stop all || true
pm2 start app.js
pm2 save

echo "Deployment successful!"
