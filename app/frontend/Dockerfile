# Stage 1
FROM --platform=linux/amd64 node:14 as build-stage

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

ARG REACT_APP_BACKEND_URL
RUN if [ ! -z "$REACT_APP_BACKEND_URL" ]; \
    then export REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL; \
    fi 
    
RUN npm run build

# Stage 2
FROM --platform=linux/amd64 nginx:1.23.0-alpine

COPY --from=build-stage /app/build /usr/share/nginx/html

EXPOSE 80

CMD nginx -g 'daemon off;'