<?php

define('WP_CONTENT_DIR', '/var/www/html/wp-content');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

$table_prefix  = getenv('TABLE_PREFIX') ?: 'wp_';

foreach ($_ENV as $key => $value) {
  $capitalized = strtoupper($key);
  if (!defined($capitalized)) {
    define($capitalized, $value);
  }
}

if (!defined('ABSPATH'))
  define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
