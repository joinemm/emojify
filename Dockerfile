ARG PORT
#
# ---- Base ----
#
FROM node:14-alpine AS base
RUN apk add --no-cache make gcc g++ python3

#
# ---- Dependencies ----
#
FROM base AS dependencies
WORKDIR /usr/src/app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --production --silent \
  && yarn cache clean \
  && apk del make gcc g++ python3 \
  && rm -rf \
  /tmp \
  /opt \
  /usr/local/share/.cache/yarn \
  /usr/local/lib/node_modules/npm \
  /root/.cache \
  /root/.npm

#
# ---- Build ----
#
FROM base as build
WORKDIR /usr/src/app
COPY ./ .

RUN yarn add typescript --dev && yarn build

#
# ---- Release ----
#
FROM dependencies AS release
WORKDIR /usr/src/app

COPY --from=build /usr/src/app/build .

ENV PORT 3000
CMD ["node", "src/main.js"]
