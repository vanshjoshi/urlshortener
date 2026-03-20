#!/bin/bash

echo "Preparing deployment..."

cd /home/ec2-user

# 1️⃣ Stop app ONLY if running
if pm2 list | grep -q "online"; then
  echo "Stopping running app..."
  pm2 stop all
else
  echo "No running app found"
fi

# 2️⃣ Check if directory exists
if [ -d "urlshortener" ]; then
  echo "Directory exists, cleaning..."
  rm -rf /home/ec2-user/urlshortener/*
else
  echo "Directory not found, creating..."
  mkdir /home/ec2-user/urlshortener
fi

echo "Preparation completed!"
