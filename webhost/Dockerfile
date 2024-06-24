FROM node:20-bookworm-slim

RUN groupadd --gid 10000 webuser \
  && useradd --uid 10001 --gid webuser --shell /bin/bash --create-home webuser \

WORKDIR /usr/webhost
COPY --chown=10001:10000 webhost/dist          /usr/webhost/dist
COPY --chown=10001:10000 webhost/package*.json /usr/webhost/
COPY --chown=10001:10000 spa/dist              /usr/webhost/content

RUN npm install --omit=dev

USER 10001

CMD ["node", "dist/server.js"]
