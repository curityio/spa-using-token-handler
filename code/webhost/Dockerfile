FROM node:15.11.0-alpine

WORKDIR /usr/webhost
COPY webhost/dist          /usr/webhost/dist
COPY webhost/package*.json /usr/webhost/
COPY ../spa/dist           /usr/webhost/content

RUN npm install --production

RUN addgroup -g 1001 webgroup
RUN adduser -u 1001 -G webgroup -h /home/webuser -D webuser

USER webuser
CMD ["node", "dist/server.js"]