FROM nginx:mainline
LABEL MAINTAINER="Toby Scales <docker@scales.cloud>"

# Update this value to your desired SSL site
ENV SSLSITE="sync.scales.cloud"

#WORKDIR /acme

# don't need to install it, copy it from the git folder
#curl https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh | INSTALLONLINE=1  sh

#COPY . /home/acme.sh

RUN apt-get update && \
    apt-get install -y -q --no-install-recommends \
    cron curl && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

RUN curl http://get.acme.sh | sh
RUN crontab -l | sed 's#> /dev/null##' | crontab -

RUN ~/.acme.sh/acme.sh --issue -d $SSLSITE -w /var/www/html --staging
RUN /home/.acme.sh/acme.sh --install-cert -d $SSLSITE \
    --cert-file /etc/nginx/certs/cert.pem \
    --key-file /etc/nginx/certs/privkey.pem \
    --fullchain-file /etc/nginx/certs/fullchain.pem \
    --reloadcmd "nginx -t && nginx -s reload"

#ENTRYPOINT ["/app/docker-entrypoint.sh"]
