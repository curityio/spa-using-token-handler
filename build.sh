#!/bin/bash

#################################################################
# A script to build code into Docker images, ready for deployment
#################################################################

#
# Build the SPA into Javascript bundles
#
cd spa
npm install
if [ $? -ne 0 ]; then
  echo "Problem encountered installing the SPA dependencies"
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  echo "Problem encountered building the SPA code"
  exit 1
fi

#
# Build the Web Host, which serves static content
#
cd ../webhost
npm install
if [ $? -ne 0 ]; then
  echo "Problem encountered installing the web host dependencies"
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  echo "Problem encountered building the web host code"
  exit 1
fi

cd ..
docker build -f webhost/Dockerfile -t webhost:1.0.0 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the web host Docker file"
  exit 1
fi

#
# Build the Example API, which receives JWTs
#
cd api
npm install
if [ $? -ne 0 ]; then
  echo "Problem encountered installing the example API dependencies"
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  echo "Problem encountered building the example API code"
  exit 1
fi

docker build -f Dockerfile -t example-api:1.0.0 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the example API Docker file"
  exit 1
fi

DEPLOYMENT_SCENARIO='basic'

#
# Get deployment dependencies, and see the [Prerequisite Setup](PREREQUISITES.md)
#
cd ..
if [ ! -d './deployment' ]; then
  git clone https://github.com/curityio/spa-deployments deployment
  if [ $? -ne 0 ]; then
    echo 'Problem encountered downloading dependencies'
    exit
  fi
fi

cd deployment
git checkout dev

if [ "$DEPLOYMENT_SCENARIO" == 'basic' ]; then
  cd basic
  ./build.sh
fi

if [ "$DEPLOYMENT_SCENARIO" == 'financial' ]; then
  cd financial
  ./build.sh
fi

#
# Report failures
#
if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi
