FROM nginx:alpine
RUN apk update && \
    apk --no-cache add shadow bash&& \
    usermod -u 1001 nginx && \
    apk del shadow
#RUN mkdir -p /var/www/chop-life-web

COPY configs/nginx.conf /etc/nginx/
COPY configs/conf.d/ /etc/nginx/conf.d/
COPY configs/.htpasswd /etc/nginx/.htpasswd

#COPY --chown=nginx --from=chop-life-node:latest /opt/app/build/ /var/www/chop-life-web/

#RUN chown -R nginx /etc/nginx/ssl/server.*
#RUN chmod 600 /etc/nginx/ssl/server.*
