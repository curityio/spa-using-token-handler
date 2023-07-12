FROM node:18-alpine

WORKDIR /usr/api
COPY package*.json      /usr/api/
COPY dist               /usr/api/dist

RUN npm install --production

RUN addgroup -g 1001 apigroup
RUN adduser -u 1001 -G apigroup -h /home/apiuser -D apiuser

USER apiuser

# If PKCS#12 files are loaded that were created with OpenSSL 1.1.1, this is needed
# https://github.com/nodejs/node/issues/40672
CMD ["node", "--openssl-legacy-provider", "dist/server.js"]