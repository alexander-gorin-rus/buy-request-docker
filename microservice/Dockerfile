FROM node:14.18.0


RUN apt update

RUN npm config set user 0
RUN npm config set unsafe-perm true

RUN npm install pm2@latest -g
USER node
