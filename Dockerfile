ARG PHP_VERSION=8.3.2
FROM php:${PHP_VERSION}-fpm-alpine

# timezone
ENV TZ=Asia/Shanghai
# tzdata
RUN set -eux && apk update && apk add tzdata && \
    # shanghai
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    # clean
    apk cache clean && rm -rf /var/cache/apk/*

# docker-php-ext-install extension
RUN apk update && apk add --no-cache \
    && apk add freetype-dev\
        libwebp-dev\
        libxpm-dev\
        libpng-dev\
        libjpeg-turbo-dev\
        libzip-dev\
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-xpm \
        --with-freetype \
    && docker-php-ext-install pdo_mysql gd zip bcmath
    
RUN apk add gcc g++ autoconf make linux-headers\
    && pecl install -o -f redis\
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# copy
COPY index.php /var/www/html/

# expose
EXPOSE 80

# command
CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/html/"]
