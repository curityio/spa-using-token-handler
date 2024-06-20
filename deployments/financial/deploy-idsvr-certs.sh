#!/bin/bash

#########################################################################
# A post deployment script for financial grade, to configure certificates
#########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

RESTCONF_BASE_URL='https://localhost:6749/admin/api/restconf/data'
ADMIN_USER='admin'
ADMIN_PASSWORD='Password1'
IDENTITY_SERVER_TLS_NAME='Identity_Server_TLS'
PRIVATE_KEY_PASSWORD='Password1'

#
# Get platform specific differences
#
case "$(uname -s)" in

  Linux)
    LINE_SEPARATOR='\n'
	;;
  
  Darwin)
    LINE_SEPARATOR='\n'
 	;;

  MINGW64*)
    LINE_SEPARATOR='\r\n'
	;;
esac

#
# Wait for the admin endpoint to become available
#
echo "Waiting for the Curity Identity Server ..."
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' -u "$ADMIN_USER:$ADMIN_PASSWORD" "$RESTCONF_BASE_URL?content=config")" != "200" ]; do
  sleep 2
done

#
# Add the SSL key and use the private key password to protect it in transit
#
export IDENTITY_SERVER_TLS_DATA=$(openssl base64 -in ./certs/example.server.p12 | tr -d "$LINE_SEPARATOR")
echo "Updating SSL certificate ..."
HTTP_STATUS=$(curl -k -s \
-X POST "$RESTCONF_BASE_URL/base:facilities/crypto/add-ssl-server-keystore" \
-u "$ADMIN_USER:$ADMIN_PASSWORD" \
-H 'Content-Type: application/yang-data+json' \
-d "{\"id\":\"$IDENTITY_SERVER_TLS_NAME\",\"password\":\"$PRIVATE_KEY_PASSWORD\",\"keystore\":\"$IDENTITY_SERVER_TLS_DATA\"}" \
-o /dev/null -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "Problem encountered updating the runtime SSL certificate: $HTTP_STATUS"
  exit 1
fi

#
# Set the SSL key as active for the runtime service role
#
HTTP_STATUS=$(curl -k -s \
-X PATCH "$RESTCONF_BASE_URL/base:environments/base:environment/base:services/base:service-role=default" \
-u "$ADMIN_USER:$ADMIN_PASSWORD" \
-H 'Content-Type: application/yang-data+json' \
-d "{\"base:service-role\": [{\"ssl-server-keystore\":\"$IDENTITY_SERVER_TLS_NAME\"}]}" \
-o /dev/null -w '%{http_code}')
if [ "$HTTP_STATUS" != '204' ]; then
  echo "Problem encountered updating the runtime SSL certificate: $HTTP_STATUS"
  exit 1
fi
