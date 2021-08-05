#!/bin/bash

#####################################################################
# A script to spin up Docker images with their deployed configuration
#####################################################################

#
# First check prerequisites
#
if [ ! -f './idsvr/license.json' ]; then
  echo "Please provide a license.json file in the deployment/idsvr folder in order to deploy the system"
  exit 1
fi

#
# Download the reverse proxy back end for front end token plugin
#
rm -rf kong-bff-plugin
git clone https://github.com/curityio/kong-bff-plugin
if [ $? -ne 0 ]; then
  echo "Problem encountered downloading the BFF plugin"
  exit 1
fi

#
# Temnporary code until the PR is passed
#
cd kong-bff-plugin
git checkout feature/csrf
cd ..

#
# Download the reverse proxy phantom token plugin
#
rm -rf kong-phantom-token-plugin
git clone https://github.com/curityio/kong-phantom-token-plugin
if [ $? -ne 0 ]; then
  echo "Problem encountered downloading the phantom token plugin"
  exit 1
fi

#
# Spin up all containers, using the Docker Compose file, which applies the deployed configuration
#
docker compose up --force-recreate
if [ $? -ne 0 ]; then
  echo "Problem encountered starting Docker components"
  exit 1
fi