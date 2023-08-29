#!/bin/sh

sed -i -- "s/worker_processes .*;/worker_processes ${WORKER_PROCESSES:-auto};/g; \
    s/worker_connections .*;/worker_connections ${WORKER_CONNECTIONS:-1024};/g; \
    s/client_max_body_size .*;/client_max_body_size ${PHP_MAX_UPLOAD_SIZE:-16M};/g; \
    s/fastcgi_read_timeout .*;/fastcgi_read_timeout ${MAX_EXECUTION_TIME:-60}s;/g" /etc/nginx/nginx.conf

echo "[www]" > /usr/local/etc/php-fpm.d/www.conf
echo "pm.max_children = ${PM_MAX_CHILDREN:-16}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[memory_limit] = ${PHP_MEMORY_LIMIT:-128M}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[upload_max_filesize] = ${PHP_MAX_UPLOAD_SIZE:-16M}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[post_max_size] = ${PHP_MAX_UPLOAD_SIZE:-16M}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[max_execution_time] = ${MAX_EXECUTION_TIME:-60}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[max_input_vars] = ${PHP_MAX_INPUT_VARS:-1000}" >> /usr/local/etc/php-fpm.d/www.conf

sh /root/prepare-entrypoint.sh

mkdir -p /var/www/html/storage/logs
rm -f /var/www/html/storage/logs/laravel.log /var/www/html/storage/logs/lumen.log
touch /var/www/html/storage/logs/laravel.log /var/www/html/storage/logs/lumen.log
chown -R www-data:www-data /var/www/html/storage

echo 'Starting nginx...'
nginx

echo 'Starting php-fpm...'
php-fpm

echo 'Ready to serve...'
parallel --line-buffer ::: /root/foreground/foreground1.sh /root/foreground/foreground2.sh
