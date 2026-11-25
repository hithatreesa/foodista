FROM nginx:alpine

LABEL maintainer="hithatreesa"

COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
