FROM node:12

WORKDIR /usr/src/app

COPY ./package.json .

RUN npm install

ENV PATH /usr/src/app/node_modules/.bin:$PATH

COPY . .