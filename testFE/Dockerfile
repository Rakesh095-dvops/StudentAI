FROM nginx:stable-alpine as test
WORKDIR /var/www/html
COPY nginx.conf /etc/nginx/nginx.conf
COPY . /var/www/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]