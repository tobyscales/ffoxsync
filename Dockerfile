FROM nginx:mainline
LABEL MAINTAINER="Toby Scales <docker@scales.cloud>"

# Update this value to your desired SSL site
ENV SSLSITE="sync.scales.cloud"

WORKDIR /acme

# don't need to install it, copy it from the git folder
#curl https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh | INSTALLONLINE=1  sh

COPY . /home/acme.sh

RUN apt-get -y update && \
    apt-get -y install curl && \
    apt-get -y install cron
RUN chmod 755 /home/acme.sh
RUN /home/acme.sh --install
RUN /home/acme.sh --issue -d $SSLSITE -w /var/www/html

RUN /home/acme.sh --install-cert -d $SSLSITE \
    --cert-file /etc/nginx/certs/cert.pem \
    --key-file /etc/nginx/certs/privkey.pem \
    --fullchain-file /etc/nginx/certs/fullchain.pem \
    --reloadcmd "service nginx reload"

#ENTRYPOINT ["/app/docker-entrypoint.sh"]
