FROM node:18-alpine

WORKDIR /usr/webhost
COPY webhost/dist          /usr/webhost/dist
COPY webhost/package*.json /usr/webhost/
COPY spa/dist              /usr/webhost/content

RUN npm install --production

RUN addgroup -g 1001 webgroup
RUN adduser -u 1001 -G webgroup -h /home/webuser -D webuser

USER webuser

# If development PKCS#12 files created with OpenSSL 1.1.1 are used, the legacy provider option may be needed
# https://github.com/nodejs/node/issues/40672
CMD ["node", "--openssl-legacy-provider", "dist/server.js"]