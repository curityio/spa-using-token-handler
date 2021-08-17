#!/bin/bash

##############################################################
# Basic automation to get tokens from the Authorization Server
##############################################################

BFF_API_BASE_URL='http://api.example.com:3000/bff'
#BFF_API_BASE_URL='http://api.example.com:3001'
WEB_BASE_URL='http://www.example.com'
AUTHORIZATION_SERVER_BASE_URL='http://login.example.com:8443'
RESPONSE_FILE=tmp/response.txt
LOGIN_COOKIES_FILE=tmp/login_cookies.txt
CURITY_COOKIES_FILE=tmp/curity_cookies.txt
MAIN_COOKIES_FILE=tmp/main_cookies.txt
TEST_USERNAME=demouser
TEST_PASSWORD=Password1
CLIENT_ID=spa-client
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
# Pattern matching to dig out a field value from an auto submit HTML form, via the second pattern match
#
function getHtmlFormValue(){
  local _FIELD_NAME=$1
  local _FIELD_LINE=$(cat $RESPONSE_FILE | grep -i "name=\"$_FIELD_NAME\"")
  local _FIELD_VALUE=$(echo $_FIELD_LINE | sed -r "s/^(.*)name=\"$_FIELD_NAME\" value=\"(.*)\"(.*)$/\2/i")
  echo $_FIELD_VALUE
}

#
# Temp data is stored in this folder
#
mkdir -p tmp

#
# First get the authorization request URL
#
HTTP_STATUS=$(curl -i -s -X POST "$BFF_API_BASE_URL/login/start" \
-H "origin: $WEB_BASE_URL" \
-H 'content-type: application/json' \
-H 'accept: application/json' \
-c $LOGIN_COOKIES_FILE \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" == '000' ]; then
  echo '*** Connectivity problem encountered, please check endpoints and whether an HTTP proxy tool is running'
  exit 1
fi
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Start login failed with status $HTTP_STATUS"
  exit 1
fi
JSON=$(tail -n 1 $RESPONSE_FILE)
echo $JSON | jq
AUTHORIZATION_REQUEST_URL=$(jq -r .authorizationRequestUrl <<< "$JSON")

#
# Follow redirects until the login HTML form is returned and save cookies
#
HTTP_STATUS=$(curl -i -L -s -X GET "$AUTHORIZATION_REQUEST_URL" \
-c $CURITY_COOKIES_FILE \
-o $RESPONSE_FILE -w '%{http_code}')
if [ $HTTP_STATUS != '200' ]; then
  echo "*** Problem encountered during an OpenID Connect authorization redirect, status: $HTTP_STATUS"
  exit 1
fi

#
# Post up the test credentials, sending then regetting cookies
#
HTTP_STATUS=$(curl -i -s -X POST "$AUTHORIZATION_SERVER_BASE_URL/authn/authentication/Username-Password" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-b $CURITY_COOKIES_FILE \
-c $CURITY_COOKIES_FILE \
--data-urlencode "userName=$TEST_USERNAME" \
--data-urlencode "password=$TEST_PASSWORD" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ $HTTP_STATUS != '200' ]; then
  echo "*** Problem encountered submitting test user credentials, status: $HTTP_STATUS"
  exit 1
fi

#
# Do the auto form post, providing Identity Server cookies
#
TOKEN=$(getHtmlFormValue 'token')
STATE=$(getHtmlFormValue 'state')
HTTP_STATUS=$(curl -i -s -X POST "$AUTHORIZATION_SERVER_BASE_URL/oauth/v2/oauth-authorize?client_id=$CLIENT_ID" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-b $CURITY_COOKIES_FILE \
-c $CURITY_COOKIES_FILE \
--data-urlencode "token=$TOKEN" \
--data-urlencode "state=$STATE" \
-o $RESPONSE_FILE -w '%{http_code}')
if [ $HTTP_STATUS != '303' ]; then
  echo "*** Problem encountered auto posting form, status: $HTTP_STATUS"
  exit 1
fi

#
# Read the response details
#
APP_URL=$(getHeaderValue 'location')
if [ "$APP_URL" == '' ]; then
  echo '*** API driven login did not complete successfully'
  exit 1
fi
PAGE_URL_JSON='{"pageUrl":"'$APP_URL'"}'
echo $PAGE_URL_JSON | jq

#
# End the login by swapping the code for tokens
#
HTTP_STATUS=$(curl -i -s -X POST "$BFF_API_BASE_URL/login/end" \
-H "origin: $WEB_BASE_URL" \
-H 'content-type: application/json' \
-H 'accept: application/json' \
-c $MAIN_COOKIES_FILE \
-b $LOGIN_COOKIES_FILE \
-d $PAGE_URL_JSON \
-o $RESPONSE_FILE -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "*** Problem encountered ending the login, status $HTTP_STATUS"
  JSON=$(tail -n 1 $RESPONSE_FILE) 
  echo $JSON | jq
  exit 1 
fi
JSON=$(tail -n 1 $RESPONSE_FILE) 
echo $JSON | jq
IS_LOGGED_IN=$(jq -r .isLoggedIn <<< "$JSON")
HANDLED=$(jq -r .handled <<< "$JSON")
if [ "$IS_LOGGED_IN" != 'true'  ] || [ "$HANDLED" != 'true' ]; then
   echo '*** End login returned an unexpected payload'
   exit 1
fi

exit 0