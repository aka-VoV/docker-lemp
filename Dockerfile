FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

## Install php nginx mysql supervisor
RUN apt-get update && \
    apt-get -y -q --no-install-recommends install -y php-fpm php-cli php-gd php-mcrypt php-mysql php-curl \
                       php-intl \
                       php-imagick \
                       php-json \
                       php-pear \
                       php-dev \
                       php7.0-sqlite \
                       nginx \
                       curl \
                       mysql-server \
                       mysql-client \
                       unzip \
                       sudo \
                       nano \
                       ssh \
                       bash-completion \
                       openssl \
                       ca-certificates \
                       wget \
                       git \
                       phpmyadmin php-mbstring php-gettext \
		       supervisor && \

		       # install composer
               	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

               # add user "docker" to use it as default user for working with files
               	yes "" | adduser --uid=1000 --disabled-password docker && \
               	echo "docker   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \

               # install composer assets plugin
               	sudo -H -u docker bash -c "/usr/local/bin/composer global require fxp/composer-asset-plugin:~1.1.3" && \

               # create and set access to the folder
               	mkdir -p /web/docker && \
               	echo "<?php echo 'web server is running';" > /web/docker/index.php && \
               	chown -R docker:docker /web && \

               	# add custom php configuration
                	phpenmod custom && \

                # enable mcrypt module
                	phpenmod mcrypt && \


    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt install -y mysql-server && \
    rm -rf /var/lib/apt/lists/*

## Configuration
RUN sed -i 's/^listen\s*=.*$/listen = 127.0.0.1:9000/' /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cgi.log/' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php\/cli.log/' /etc/php/7.0/cli/php.ini && \
    sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf

COPY files/root /

WORKDIR /web

VOLUME ["/web", "/var/lib/mysql"]

EXPOSE 80 443 3306 9000

ENTRYPOINT ["/entrypoint.sh"]
