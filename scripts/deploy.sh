#!/bin/bash

echo "Starting deployment..."

# Go to app directory
cd /home/ec2-user/urlshortener || exit

echo "Installing dependencies..."
npm install

echo "Restarting app..."

# Install pm2 if not exists
which pm2 || sudo npm install -g pm2

pm2 stop app || true
pm2 start app.js --name app
pm2 save

echo "Deployment successful!"
