#!/bin/bash

##############################################################
# Get and build code into Docker images, ready for deployment
##############################################################

if [ "$1" == 'financial' ]; then
  DEPLOYMENT_SCENARIO='financial'
else
  DEPLOYMENT_SCENARIO='standard'
fi

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# This is for Curity developers only
#
cp ./hooks/pre-commit .git/hooks

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

docker build -f Dockerfile -t business-api:1.0.0 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the example API Docker file"
  exit 1
fi
cd ..

#
# Get deployment resources, including the token handler
#
rm -rf resources
git clone https://github.com/curityio/spa-deployments resources
if [ $? -ne 0 ]; then
  echo 'Problem encountered downloading dependencies'
  exit
fi

# TODO: 
cd resources
git checkout feature/cookie-updates
cd ..

#
# Build resources by running the child script
#
cd "./resources/$DEPLOYMENT_SCENARIO"
./build.sh
if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi
