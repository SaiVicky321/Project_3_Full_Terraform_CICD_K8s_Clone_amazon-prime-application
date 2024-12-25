FROM node:current-alpine3.21

WORKDIR /app

COPY package* /app/

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]