FROM node:12

WORKDIR /usr/src/app

COPY ./package.json .

RUN npm install \
&& npm install nodemon -g

ENV PATH /usr/src/app/node_modules/.bin:$PATH

COPY . .