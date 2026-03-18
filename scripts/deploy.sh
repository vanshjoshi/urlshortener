#!/bin/bash

echo "Deploying application..."

cd /home/ec2-user/urlshortener || exit

echo "Installing dependencies..."
npm install

echo "Starting app..."

which pm2 || sudo npm install -g pm2

pm2 start app.js || pm2 restart app.js
pm2 save

echo "Deployment complete!"
