FROM --platform=linux/amd64 node:14-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

CMD npm start