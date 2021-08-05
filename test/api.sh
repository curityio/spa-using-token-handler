#!/bin/bash

################################################################################################
# Tests to visualize behaviour when calling the example API with secure cookies, via the gateway
# This ensures that we get responses useful to the SPA and error responses that are readable
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
if [ "$ORIGIN" == 'http://malicious-site.com' ]; then
  echo '*** CORS access was granted to a malicious origin'
  exit
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
# Test a POST request for data from an untrusted web origin
#
echo '3. Testing API POST request with an invalid origin ...'
HTTP_STATUS=$(curl -i -s -X POST "$API_BASE_URL/data" \
-H "origin: http://malicious-site.com" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '401' ]; then
  echo '*** The expected error did not occur when calling an API from an untrusted origin'
  exit
fi
JSON=$(tail -n 1 $RESPONSE_FILE)
echo $JSON | jq
CODE=$(jq -r .code <<< "$JSON")
if [ "$CODE" != 'unauthorized' ]; then
   echo '*** POST from an untrusted origin returned an unexpected error code'
   exit
fi
ORIGIN=$(getHeaderValue 'Access-Control-Allow-Origin')
if [ "$ORIGIN" != "$WEB_BASE_URL" ]; then
  echo '*** The error response is not readable by the SPA'
  exit
fi
echo '3. POST from an untrusted origin was successfully rejected'

#
# Test a POST request for data without a secure cookie and also verify that the SPA can read the response
#
echo '4. Testing API POST request without a secure cookie ...'
HTTP_STATUS=$(curl -i -s -X POST "$API_BASE_URL/data" \
-H "origin: $WEB_BASE_URL" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '401' ]; then
  echo '*** The expected error did not occur when calling an API without a secure cookie'
  exit
fi
JSON=$(tail -n 1 $RESPONSE_FILE)
echo $JSON | jq
CODE=$(jq -r .code <<< "$JSON")
if [ "$CODE" != 'unauthorized' ]; then
   echo '*** API POST without a secure cookie returned an unexpected error code'
   exit
fi
echo '4. POST without a valid secure cookie was successfully rejected'

#
# Do a login to get a secure cookie with which to call the API
#
echo '5. Performing API driven login ...'
./login.sh
if [ "$?" != '0' ]; then
  echo '*** Problem encountered implementing an API driven login'
  exit
fi
JSON=$(tail -n 1 $RESPONSE_FILE) 
echo $JSON | jq
CSRF=$(jq -r .csrf <<< "$JSON")
echo $CSRF
echo '5. API driven login completed successfully'

#
# Test a POST request for data without an anti forgery token
#
echo '6. Testing API request without an anti forgery token ...'
HTTP_STATUS=$(curl -i -s -X POST "$API_BASE_URL/data" \
-H "origin: $WEB_BASE_URL" \
-b $MAIN_COOKIES_FILE \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '401' ]; then
  echo '*** The expected error did not occur when calling an API without an anti forgery token'
  exit
fi
JSON=$(tail -n 1 $RESPONSE_FILE)
echo $JSON | jq
CODE=$(jq -r .code <<< "$JSON")
if [ "$CODE" != 'unauthorized' ]; then
   echo '*** API POST without an anti forgery token returned an unexpected error code'
   exit
fi
echo '6. POST without an anti forgery token was successfully rejected'

#
# Test a POST request for data without an incorrect anti forgery token
#
echo '7. Testing API request with an incorrect anti forgery token ...'
HTTP_STATUS=$(curl -i -s -X POST "$API_BASE_URL/data" \
-H "origin: $WEB_BASE_URL" \
-H "x-example-csrf: abc123" \
-b $MAIN_COOKIES_FILE \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '401' ]; then
  echo '*** The expected error did not occur when calling an API an incorrect anti forgery token'
  exit
fi
JSON=$(tail -n 1 $RESPONSE_FILE)
echo $JSON | jq
CODE=$(jq -r .code <<< "$JSON")
if [ "$CODE" != 'unauthorized' ]; then
   echo '*** API POST with an incorrect anti forgery token returned an unexpected error code'
   exit
fi
echo '7. POST with an incorrect anti forgery token was successfully rejected'

#
# Test a successful POST request
#
echo '8. Testing API request with correct message credentials ...'
HTTP_STATUS=$(curl -i -s -X POST "$API_BASE_URL/data" \
-H "origin: $WEB_BASE_URL" \
-H "x-example-csrf: $CSRF" \
-b $MAIN_COOKIES_FILE \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** The API request failed unexpectedly, with status $HTTP_STATUS"
  exit
fi
echo '8. POST with valid message credentials was succesfully processed'