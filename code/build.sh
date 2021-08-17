#!/bin/bash

########################################################################
# A script to build code and produce Docker images, ready for deployment
########################################################################

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
# Build the web host code
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
# Build the example API
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

#
# Get and build the BFF API here
#
cd ..
rm -rf bff-node-express
git clone https://github.com/curityio/bff-node-express
if [ $? -ne 0 ]; then
  echo "Problem encountered downloading the BFF API"
  exit 1
fi

cd bff-node-express
npm install
if [ $? -ne 0 ]; then
  echo "Problem encountered installing the BFF API dependencies"
  exit 1
fi

npm run build
if [ $? -ne 0 ]; then
  echo "Problem encountered building the BFF API code"
  exit 1
fi

docker build -f Dockerfile -t bff-api:1.0.0 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the BFF API Docker file"
  exit 1
fi
