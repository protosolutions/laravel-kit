FROM ubuntu:20.04
ENV TZ=UTC
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y nginx php-fpm php-mysqlnd php-pgsql php-pdo php-gd php-xmlrpc php-xml php-mbstring php-pear php-json php-zip git vim wget curl unzip zip composer
RUN sed -i -e 's/try_files/#try_files/g' /etc/nginx/sites-enabled/default
RUN sed -i -E '/^[[:space:]]+location \/ \{/a \\t\ttry_files $uri $uri\/ \/index.php?$query_string;' /etc/nginx/sites-enabled/default
RUN sed -i -E '/^[[:space:]]+server_name/a \\tinclude /etc/nginx/php-fpm.conf;' /etc/nginx/sites-enabled/default
RUN composer global require laravel/installer
ENV PATH "$PATH:/root/.composer/vendor/bin"
COPY entrypoint.sh /
RUN unlink /etc/nginx/sites-enabled/default
COPY nginx-php-site /etc/nginx/sites-enabled/
RUN chmod 755 /entrypoint.sh
WORKDIR /var/www/html
EXPOSE 80/tcp
CMD /entrypoint.sh
