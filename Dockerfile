# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# install app dependencies
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata apache2 curl php php-image-text php-gd git mysql-client inetutils-ping php-mysql

#Set post max size to 0
RUN sed -i 's/post_max_size = 8M/post_max_size = 0/' /etc/php/8.1/apache2/php.ini 

#Enable Extensions
RUN sed -i 's/;extension=gd/extension=gd/' /etc/php/8.1/apache2/php.ini

RUN sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' /etc/php/8.1/apache2/php.ini

#Prep directory for web root
RUN rm -rf /var/www/html/index.html 

#Clone
RUN git clone https://github.com/librespeed/speedtest.git /var/www/html

#change telemetry settings
RUN sed -i 's/USERNAME/speedtest/' /var/www/html/results/telemetry_settings.php
RUN sed -i 's/PASSWORD/speedtest/' /var/www/html/results/telemetry_settings.php
RUN sed -i 's/DB_HOSTNAME/mysql/' /var/www/html/results/telemetry_settings.php
RUN sed -i 's/DB_NAME/kptspeedtest/' /var/www/html/results/telemetry_settings.php

#Remove extra files:
RUN  rm /var/www/html/Dockerfile* /var/www/html/LICENSE /var/www/html/*.md
RUN rm -rf /var/www/html/docker/ /var/www/html/docker/examples/

#Mod permissions
RUN chown -R www-data /var/www/html/
RUN chgrp -R www-data /var/www/html/

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
HEALTHCHECK --timeout=3s \
  CMD curl -f http://localhost/ || exit 1