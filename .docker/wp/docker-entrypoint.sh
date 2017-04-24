#!/usr/bin/env bash

set -ex

# Copy WordPress core.
if ! [ -e index.php ] && ! [ -e wp-includes/version.php ]; then
  tar cf - --one-file-system -C /usr/src/wordpress . | tar xf - --owner="$(id -u www-data)" --group="$(id -g www-data)"
  echo "WordPress has been successfully copied to $(pwd)"
fi

ls /var/www/html

# Create WordPress config.
if ! [ -f /var/www/html/wp-config.php ]; then
  echo "Creating WP config"
  wp core config \
  --dbhost="'${DB_HOST:-mysql}'" \
  --dbname="'${DB_NAME:-wordpress}'" \
  --dbuser="'${DB_USER:-root}'" \
  --dbpass="'$DB_PASSWORD'" \
  --skip-check \
  --extra-php <<PHP
  $WORDPRESS_CONFIG_EXTRA
PHP
fi

# Update WP-CLI config with current virtual host.
sed -i -E "s/^url: .*/url: ${VIRTUAL_HOST:-project.dev}/" /etc/wp-cli/config.yml

# MySQL may not be ready when container starts.
set +ex
while true; do
  curl --fail --show-error --silent "${WORDPRESS_DB_HOST:-mysql}:3306" > /dev/null 2>&1
  if [ $? -eq 0 ]; then break; fi
  echo "Waiting for MySQL to be ready...."
  sleep 3
done
>&2 echo "MySQL is up - executing command."

set -ex

# Install WordPress
wp core install \
  --title="'${WORDPRESS_SITE_TITLE:-Project}'" \
  --admin_user="'${WORDPRESS_SITE_USER:-wordpress}'" \
  --admin_password="'${WORDPRESS_SITE_PASSWORD:-wordpress}'" \
  --admin_email="'${WORDPRESS_SITE_EMAIL:-admin@example.com}'" \
  --skip-email

# Activate theme.
if [ -n "$WORDPRESS_ACTIVATE_THEME" ]; then
  wp theme activate "$WORDPRESS_ACTIVATE_THEME"
fi

exec "$@"
