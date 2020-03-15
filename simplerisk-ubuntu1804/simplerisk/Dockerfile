# Use the bionic image
FROM ubuntu:bionic

# The build artifact
ARG simplerisk_build_artifact

# Maintained by SimpleRisk
LABEL maintainer="SimpleRisk <support@simplerisk.com>"

# Update the image to the latest packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
  && apt-get upgrade -y

# Make necessary directories
RUN mkdir -p /var/log && \
    mkdir -p /etc/apache2/ssl && \
    mkdir -p /var/www/simplerisk/ssl

# Install required packages
RUN dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 \
    libmcrypt-dev \
    mysql-client \
    nfs-common chrony \
    php \
    php-dev \
    php-json \
    php-ldap \
    php-pear \
    php7.2-mbstring \
    php-mysql \
    openssl \
    python-setuptools \
    sendmail \
    supervisor \
    ufw \
    vim-tiny && \
    pecl channel-update pecl.php.net && \
    yes '' | pecl install mcrypt-1.0.1 && \
    sed -i 's/;extension=xsl/;extension=xsl\nextension=mcrypt.so/g' /etc/php/7.2/apache2/php.ini && \
    sed -i 's/;extension=xsl/;extension=xsl\nextension=mcrypt.so/g' /etc/php/7.2/cli/php.ini

# Install and configure supervisor
COPY ./supervisord.conf /etc/supervisord.conf
RUN service supervisor restart

# Configure Apache
COPY ./envvars /etc/apache2/envvars
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
COPY ./foreground.sh /etc/apache2/foreground.sh
RUN chmod 755 /etc/apache2/foreground.sh && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 5M/g' /etc/php/7.2/apache2/php.ini
COPY ./start.sh /start.sh

# Activate Apache modules
RUN phpenmod ldap && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2enmod lbmethod_byrequests && \
    a2enconf security && \
    sed -i 's/SSLProtocol all -SSLv3/SSLProtocol TLSv1.2/g' /etc/apache2/mods-enabled/ssl.conf &&\
    sed -i 's/#SSLHonorCipherOrder on/SSLHonorCipherOrder on/g' /etc/apache2/mods-enabled/ssl.conf &&\
    sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-enabled/security.conf &&\
    sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/apache2/conf-enabled/security.conf

RUN echo %sudo  ALL=NOPASSWD: ALL >> /etc/sudoers

# Copy SimpleRisk build artifact
COPY $simplerisk_build_artifact /simplerisk.tgz

# Get Azure MySQL certificate to enable SSL connections to Azure
ADD https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem /var/www/simplerisk/ssl

# Extract the SimpleRisk files
RUN rm -rf /var/www/html && \
    cd /var/www && \
    tar xvzf /simplerisk.tgz && \
    chown -R www-data: /var/www/simplerisk && \
    cp /var/www/simplerisk/includes/config.php /var/www/config.orig.php

EXPOSE 80
EXPOSE 443

#RUN useradd --no-log-init -m -G www-data sruser
#USER sruser

# Start Apache and MySQL
CMD ["/bin/bash", "/start.sh"]

