#!/bin/bash

##################################################################
# A script to free Docker resources when finished with development
##################################################################

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
# Free resources by running the child script
#
cd "./resources/$DEPLOYMENT_SCENARIO"
./teardown.sh
