#!/bin/bash

echo "Starting deployment..."

cd /home/ec2-user/urlshortener

echo "Installing dependencies..."
npm ci --omit=dev --no-audit

echo "Starting app..."
pm2 start app.js
pm2 save

echo "Deployment completed!"
