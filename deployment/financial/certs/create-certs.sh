#!/bin/bash

########################################################################
# A script to create development certificates used for local development
########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Fail on first error
#
set -e

#
# Point to the OpenSsl configuration file for the platform
#
case "$(uname -s)" in

  # Mac OS
  Darwin)
    export OPENSSL_CONF='/System/Library/OpenSSL/openssl.cnf'
 	;;

  # Windows with Git Bash
  MINGW64*)
    export OPENSSL_CONF='C:/Program Files/Git/usr/ssl/openssl.cnf';
    export MSYS_NO_PATHCONV=1;
	;;
esac

#
# First create the extensions.cnf file with the runtime domains
#
envsubst < ./extensions-template.cnf > ./extensions.cnf

#
# Define root certificate parameters
#
TRUSTSTORE_FILE_PREFIX='example.ca'
TRUSTSTORE_PASSWORD='Password1'
TRUSTSTORE_NAME="Self Signed CA for $BASE_DOMAIN"

#
# Define server certificate parameters
#
SERVER_KEYSTORE_FILE_PREFIX='example.server'
SERVER_KEYSTORE_PASSWORD='Password1'
WILDCARD_DOMAIN_NAME="*.$BASE_DOMAIN"

#
# Define client certificate parameters used for Mutual TLS
#
CLIENT_KEYSTORE_FILE_PREFIX='example.client'
CLIENT_KEYSTORE_NAME="financial-grade-spa, OU=$BASE_DOMAIN, O=Curity AB, C=SE"
CLIENT_KEYSTORE_PASSWORD='Password1'

#
# Check for OpenSSL v3
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install OpenSSL version 3 before running this script'
  exit 1
fi

#
# Create the root certificate public + private key protected by a passphrase
#
openssl genrsa -out $TRUSTSTORE_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  exit 1
fi
echo 'Successfully created Root CA key'

openssl req \
    -x509 \
    -new \
    -nodes \
    -key $TRUSTSTORE_FILE_PREFIX.key \
    -out $TRUSTSTORE_FILE_PREFIX.pem \
    -subj "/CN=$TRUSTSTORE_NAME" \
    -reqexts v3_req \
    -extensions v3_ca \
    -sha256 \
    -days 3650
if [ $? -ne 0 ]; then
  exit 1
fi
echo 'Successfully created Root CA'

#
# Create the SSL wildcard certificate and key, exported to a password protected P12 file
#
openssl genrsa -out $SERVER_KEYSTORE_FILE_PREFIX.key 2048

openssl req \
    -new \
    -key $SERVER_KEYSTORE_FILE_PREFIX.key \
    -out $SERVER_KEYSTORE_FILE_PREFIX.csr \
    -subj "/CN=$WILDCARD_DOMAIN_NAME"
if [ $? -ne 0 ]; then
  exit 1
fi

openssl x509 -req \
    -in $SERVER_KEYSTORE_FILE_PREFIX.csr \
    -CA $TRUSTSTORE_FILE_PREFIX.pem \
    -CAkey $TRUSTSTORE_FILE_PREFIX.key \
    -CAcreateserial \
    -out $SERVER_KEYSTORE_FILE_PREFIX.pem \
    -sha256 \
    -days 365 \
    -extfile extensions.cnf \
    -extensions server_ext
if [ $? -ne 0 ]; then
  exit 1
fi

openssl pkcs12 \
    -export -inkey $SERVER_KEYSTORE_FILE_PREFIX.key \
    -in $SERVER_KEYSTORE_FILE_PREFIX.pem \
    -name $WILDCARD_DOMAIN_NAME \
    -out $SERVER_KEYSTORE_FILE_PREFIX.p12 \
    -passout pass:$SERVER_KEYSTORE_PASSWORD
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create the client certificate that the example merchant will use
#
openssl genrsa -out $CLIENT_KEYSTORE_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  exit 1
fi

openssl req \
    -new \
    -key $CLIENT_KEYSTORE_FILE_PREFIX.key \
    -out $CLIENT_KEYSTORE_FILE_PREFIX.csr \
    -subj "/CN=$CLIENT_KEYSTORE_NAME"
if [ $? -ne 0 ]; then
  exit 1
fi

openssl x509 -req \
    -in $CLIENT_KEYSTORE_FILE_PREFIX.csr \
    -CA $TRUSTSTORE_FILE_PREFIX.pem \
    -CAkey $TRUSTSTORE_FILE_PREFIX.key \
    -CAcreateserial \
    -out $CLIENT_KEYSTORE_FILE_PREFIX.pem \
    -sha256 \
    -days 365 \
    -extfile extensions.cnf \
    -extensions client_ext
if [ $? -ne 0 ]; then
  exit 1
fi

openssl pkcs12 \
    -export -inkey $CLIENT_KEYSTORE_FILE_PREFIX.key \
    -in $CLIENT_KEYSTORE_FILE_PREFIX.pem \
    -name $CLIENT_KEYSTORE_FILE_PREFIX \
    -out $CLIENT_KEYSTORE_FILE_PREFIX.p12 \
    -passout pass:$CLIENT_KEYSTORE_PASSWORD
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Java trust stores work best when also password protected, so use a P12 file for the root also
#
openssl pkcs12 \
    -export -inkey $TRUSTSTORE_FILE_PREFIX.key \
    -in $TRUSTSTORE_FILE_PREFIX.pem \
    -name $TRUSTSTORE_FILE_PREFIX \
    -out $TRUSTSTORE_FILE_PREFIX.p12 \
    -passout pass:$TRUSTSTORE_PASSWORD
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Ensure that certificate files are readable, if OpenSSL 3 is used
#
chmod 644 example.ca.*
chmod 644 example.server.*
chmod 644 example.client.*

#
# Remove files we no longer need
#
rm example.server.csr
rm example.client.csr
echo '*** Successfully created all certificate files'
