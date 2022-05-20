#!/bin/bash

##################################################################
# A script to free Docker resources when finished with development
##################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Free resources by running the child script
#
./resources/teardown.sh
