FROM nginx:1.11-alpine
MAINTAINER Michael Ries <michael@riesd.com>
COPY _site /usr/share/nginx/html
