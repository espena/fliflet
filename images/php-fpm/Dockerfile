FROM php:fpm
RUN docker-php-ext-install mysqli
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
