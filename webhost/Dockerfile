FROM node:18-bullseye

WORKDIR /usr/webhost
COPY webhost/dist          /usr/webhost/dist
COPY webhost/package*.json /usr/webhost/
COPY spa/dist              /usr/webhost/content

RUN npm install --production

RUN groupadd --gid 10000 webuser \
  && useradd --uid 10001 --gid webuser --shell /bin/bash --create-home webuser
USER 10001

# If development PKCS#12 files are created with OpenSSL 1.1.1, the legacy provider option may be needed
# https://github.com/nodejs/node/issues/40672
CMD ["node", "--openssl-legacy-provider", "dist/server.js"]