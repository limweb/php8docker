FROM ubuntu:20.04 as install

WORKDIR /var/www/html
USER root
# -----install php8-----------
RUN apt update
RUN apt -y upgrade
RUN apt install -y lsb-release ca-certificates apt-transport-https software-properties-common -y
RUN add-apt-repository ppa:ondrej/php
RUN apt -y install php8.1
RUN apt install -y php8.1-amqp php8.1-common php8.1-gd php8.1-ldap php8.1-odbc php8.1-readline  php8.1-sqlite3 php8.1-xsl php8.1-apcu php8.1-curl   php8.1-gmp    php8.1-opcache  php8.1-redis  php8.1-mbstring  php8.1-pgsql    php8.1-yaml php8.1-dev    php8.1-imagick   php8.1-memcached php8.1-uuid   php8.1-zip php8.1-bz2   php8.1-zmq php8.1-interbase php8.1-mysql  php8.1-soap  php8.1-cli    php8.1-fpm    php8.1-intl   php8.1-oauth  php8.1-xml php8.1-mongodb
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY deploy/dev58/www.conf  /etc/php/8.1/fpm/pool.d/www.conf


# ----- Install Caddy --------
RUN apt install -y debian-keyring debian-archive-keyring apt-transport-https
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | apt-key add -
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
RUN apt update
RUN apt install caddy
RUN caddy version
RUN setcap 'cap_net_bind_service=+ep' /usr/bin/caddy
COPY deploy/dev58/config /etc/php/8.1/fpm/conf.d

# COPY application  /var/www/html/application
# COPY assets /var/www/html/assets
# COPY src /var/www/html/src
# COPY system /var/www/html/system
# COPY index.php /var/www/html/index.php
# COPY .htaccess /var/www/html/.htaccess
COPY src/index.php  /var/www/html/index.php

RUN  mkdir /run/php
COPY deploy/dev58/Caddyfile /etc/caddy/
COPY deploy/dev58/php-caddy-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/php-caddy-entrypoint

# RUN  apt install -y  net-tools
RUN apt-get clean autoclean
RUN apt-get autoremove --yes
RUN rm -rf /var/lib/{apt,dpkg,cache,log}/

EXPOSE 8080
ENTRYPOINT [ "php-caddy-entrypoint" ]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
# CMD ["sleep","8000"]