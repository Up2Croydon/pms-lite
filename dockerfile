# ==============================
# Stage 1: PHP dependencies
# ==============================
FROM composer:2 AS composer

WORKDIR /app

COPY . .

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev


# ==============================
# Stage 2: Frontend build
# ==============================
FROM node:22-alpine AS frontend

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# 把 Composer dependencies 放进来
COPY --from=composer /app/vendor ./vendor

RUN npm run build


# ==============================
# Stage 3: Production
# ==============================
FROM php:8.5-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install \
    pdo_mysql \
    pdo_sqlite \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd

COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

COPY --from=composer /app/vendor ./vendor

COPY --from=frontend /app/public/build ./public/build

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]