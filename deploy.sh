#!/bin/bash

#####################################################################################################
# Deploy all Docker containers to a local Docker compose network, and run the SPA locally if required
#####################################################################################################

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
# Forward the type of each component to the child script
#
OAUTH_AGENT="$1"
OAUTH_PROXY="$2"

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
./deployment/deploy.sh $OAUTH_AGENT $OAUTH_PROXY
if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi

#
# If running in development mode, run the SPA locally
#
if [ "$DEVELOPMENT" == 'true' ]; then
  cd spa
  npm start
fi
