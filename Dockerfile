FROM node:8.9.1

ENV HOST 0.0.0.0

RUN mkdir -p /app

EXPOSE 3000

COPY . /app
WORKDIR /app
RUN npm install
RUN npm run build

CMD [ "npm", "start" ]
