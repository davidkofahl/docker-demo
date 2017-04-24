FROM php:7.1-fpm-alpine

# docker-entrypoint.sh dependencies
RUN apk add --no-cache \
  sudo \
# in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
  bash \
# BusyBox sed is not sufficient for some of our sed expressions
  sed

# install the PHP extensions we need
RUN set -ex; \
  \
  apk add --no-cache --virtual .build-deps \
    libjpeg-turbo-dev \
    libpng-dev \
  ; \
  \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
  docker-php-ext-install gd mysqli opcache; \
  \
  runDeps="$( \
    scanelf --needed --nobanner --recursive \
      /usr/local/lib/php/extensions \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
  )"; \
  apk add --virtual .wordpress-phpexts-rundeps $runDeps; \
  apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
  echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini


ENV WP_ROOT /usr/src/wordpress
ENV WP_VERSION 4.7.3
ENV WP_SHA1 35adcd8162eae00d5bc37f35344fdc06b22ffc98
ENV WP_DOWNLOAD_URL https://wordpress.org/wordpress-$WP_VERSION.tar.gz

# Install wp core
RUN set -ex; \
  curl -o wordpress.tar.gz -SL $WP_DOWNLOAD_URL; \
  echo "$WP_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
  tar -xzf wordpress.tar.gz -C $(dirname $WP_ROOT); \
  rm wordpress.tar.gz; \
  chown -R www-data:www-data $WP_ROOT

# Install wp-cli
RUN curl -sSL -o /usr/local/bin/wp-cli "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
  && chmod +x /usr/local/bin/wp-cli

RUN mkdir -p /etc/wp-cli \
  && { \
  echo 'path: /var/www/html'; \
  echo 'url: project.dev'; \
} > /etc/wp-cli/config.yml

RUN { \
  echo '#!/usr/bin/env sh'; \
  echo 'sudo -E -u www-data /bin/sh -c "WP_CLI_CONFIG_PATH=/etc/wp-cli/config.yml /usr/local/bin/wp-cli $*"'; \
} > /usr/local/bin/wp \
&& chmod +x /usr/local/bin/wp

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["php-fpm"]
