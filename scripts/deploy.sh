#!/bin/bash

echo "Starting deployment..."

cd /home/ec2-user

# Stop old app (if running)
pm2 stop all || true

# Remove old code
rm -rf urlshortener

# (CodeDeploy already copied new files here)
cd /home/ec2-user/urlshortener

echo "Installing dependencies..."
npm install

echo "Starting app..."
pm2 start app.js
pm2 save

echo "Deployment completed!"
