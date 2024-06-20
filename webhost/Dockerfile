FROM node:20-bookworm-slim

WORKDIR /usr/webhost
COPY webhost/dist          /usr/webhost/dist
COPY webhost/package*.json /usr/webhost/
COPY spa/dist              /usr/webhost/content

RUN npm install --production

RUN groupadd --gid 10000 webuser \
  && useradd --uid 10001 --gid webuser --shell /bin/bash --create-home webuser
USER 10001

CMD ["node", "dist/server.js"]