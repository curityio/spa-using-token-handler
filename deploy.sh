#!/bin/bash

#####################################################################
# A script to spin up Docker images with their deployed configuration
#####################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First check prerequisites
#
if [ ! -f './license.json' ]; then
  echo 'Please provide a license.json file in the root folder in order to deploy the system'
  exit 1
fi

#
# These can be edited to use different test domains for the SPA, API and Authorization Server
#
export BASE_DOMAIN='example.com'
export WEB_SUBDOMAIN='www'
export API_SUBDOMAIN='api'
export IDSVR_SUBDOMAIN='login'

#
# If configured, an external identity server will be used
#
export EXTERNAL_IDSVR_ISSUER_URI=

#
# Support these OAuth Agent scenarios and default to the simpler Node.js implementation
#
if [ "$1" == 'financial' ]; then
  OAUTH_AGENT='financial'
else
  OAUTH_AGENT='standard'
fi

#
# Support these OAuth Proxy scenarios and default to Kong Open Source
#
if [ "$2" == 'nginx' ]; then
  OAUTH_PROXY='nginx'
elif [ "$2" == 'openresty' ]; then  
  OAUTH_PROXY='openresty'
else
  OAUTH_PROXY='kong'
fi

#
# Check that the build script has been run
#
if [ ! -d 'resources' ]; then
  echo 'Please run the build script before running the deployment script'
  exit 1
fi

#
# Copy in the license file
#
cp ./license.json ./resources/components/idsvr/

#
# Deploy resources by running the child script
#
./resources/deploy.sh $OAUTH_AGENT $OAUTH_PROXY
if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi
