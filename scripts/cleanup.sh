#!/bin/bash

echo "Stopping application..."

pm2 stop all || true

echo "Cleaning old files..."

# Remove all contents inside folder (NOT the folder itself)
rm -rf /home/ec2-user/urlshortener/*
