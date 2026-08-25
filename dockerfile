# 使用 PHP 8.5 FPM 基础镜像
FROM php:8.5-fpm

# 安装系统依赖和 PHP 扩展
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 复制项目文件（排除 .env 等）
COPY . .

# 安装 PHP 依赖（生产环境不安装开发依赖）
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 设置目录权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 生成应用密钥（需要从 .env 读取，这里先占位）
RUN php artisan key:generate --show || true

EXPOSE 9000
CMD ["php-fpm"]