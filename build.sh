#!/bin/bash

#############################################################################################################
# Builds application components into Docker containers, then runs a child script to build security components
#############################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# This is for Curity developers only
#
cp ./hooks/pre-commit .git/hooks

#
# Forward the type of each component to the child script
#
OAUTH_AGENT="$1"
OAUTH_PROXY="$2"

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
# Build security components using the child script
#
./deployments/build.sh $OAUTH_AGENT $OAUTH_PROXY

#
# Build security components by running the child script
#

if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi
