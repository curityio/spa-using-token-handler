FROM node:18-bullseye

WORKDIR /usr/api
COPY package*.json      /usr/api/
COPY dist               /usr/api/dist

RUN npm install --production

RUN groupadd --gid 10000 apiuser \
  && useradd --uid 10001 --gid apiuser --shell /bin/bash --create-home apiuser
USER 10001

# If development PKCS#12 files are created with OpenSSL 1.1.1, the legacy provider option may be needed
# https://github.com/nodejs/node/issues/40672
CMD ["node", "--openssl-legacy-provider", "dist/server.js"]