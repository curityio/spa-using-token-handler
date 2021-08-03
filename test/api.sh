#!/bin/bash

################################################################################################
# Tests to visualize behaviour when calling the example API with secure cookies, via the gateway
# This ensures that we get responses useful to the SPA and readable error responses
################################################################################################

API_BASE_URL='http://api.example.com:3000/api'
WEB_BASE_URL='http://www.example.com'
RESPONSE_FILE=tmp/response.txt
MAIN_COOKIES_FILE=tmp/main_cookies.txt
#export http_proxy='http://127.0.0.1:8888'

#
# Get a header value from the HTTP response file
#
function getHeaderValue(){
  local _HEADER_NAME=$1
  local _HEADER_VALUE=$(cat $RESPONSE_FILE | grep -i "^$_HEADER_NAME" | sed -r "s/^$_HEADER_NAME: (.*)$/\1/i")
  local _HEADER_VALUE=${_HEADER_VALUE%$'\r'}
  echo $_HEADER_VALUE
}

#
# Temp data is stored in this folder
#
mkdir -p tmp

#
# Test sending an invalid web origin to the API in an OPTIONS request
# The logic around CORS is configured, not coded, so ensure that it works as expected
#
echo '1. Testing OPTIONS request with an invalid web origin ...'
HTTP_STATUS=$(curl -i -s -X OPTIONS "$API_BASE_URL/data" \
-H "origin: http://malicious-site.com" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" == '000' ]; then
  echo '*** Connectivity problem encountered, please check endpoints and whether an HTTP proxy tool is running'
  exit
fi
ORIGIN=$(getHeaderValue 'Access-Control-Allow-Origin')
if [ "$ORIGIN" != '' ]; then
  echo '*** CORS access was granted to a malicious origin'
  #exit
fi
echo '1. OPTIONS with invalid web origin was not granted access'

#
# Test sending a valid web origin to the API in an OPTIONS request
#
echo '2. Testing OPTIONS request with a valid web origin ...'
HTTP_STATUS=$(curl -i -s -X OPTIONS "$API_BASE_URL/data" \
-H "origin: $WEB_BASE_URL" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '200'  ] && [ "$HTTP_STATUS" != '204' ]; then
  echo "*** Problem encountered requesting cross origin access, status: $HTTP_STATUS"
  exit
fi
ORIGIN=$(getHeaderValue 'Access-Control-Allow-Origin')
if [ "$ORIGIN" != "$WEB_BASE_URL" ]; then
  echo '*** The Access-Control-Allow-Origin response header has an unexpected value'
  exit
fi
echo '2. OPTIONS with valid web origin granted access successfully'

#
# Test a POST request for data without a secure cookie
# Verify CORS headers so that the SPA can read the response
#

#
# Do a login to get a secure cookie with which to call the API
#
echo '3. Performing API driven login ...'
./login.sh
if [ "$?" != '0' ]; then
  echo '*** Problem encountered implementing an API driven login'
  exit
fi
echo '3. API driven login completed successfully'

#
# Test a POST request for data without an anti forgery token
#

#
# Test a successful POST request
#
