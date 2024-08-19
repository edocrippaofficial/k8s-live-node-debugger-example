FROM node:22.6.0-alpine as build

WORKDIR /build-dir

COPY package.json .
COPY package-lock.json .

RUN npm ci

COPY . .

########################################################################################################################

FROM node:22.6.0-alpine

RUN apk add --no-cache tini

WORKDIR /home/node/app

COPY --from=build /build-dir ./

USER node

ENTRYPOINT ["/sbin/tini", "--"]

CMD node index.js
