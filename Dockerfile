FROM ricc/composer-prestissimo as vendor
FROM php:7.3.5-cli-alpine

ARG DEV
ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /var/www

# Run composer from builder image
COPY --from=vendor /usr/bin/composer /usr/bin/composer
COPY --from=vendor /tmp /root/.composer
COPY composer.json composer.lock ./

RUN if [ "$DEV" = true ] ; \
    then composer install --no-scripts --no-autoloader; \
    else composer install --no-dev --no-scripts --prefer-dist --no-progress --no-autoloader \
      && composer dump-autoload --optimize; \
    fi
RUN composer install --no-dev --no-scripts --prefer-dist --no-progress --no-autoloader \
 && composer dump-autoload --optimize

# Copy main PHP config files
COPY .cicd/docker/files/php.ini /usr/local/etc/php/conf.d/php.ini

COPY . ./

ENTRYPOINT ["php", "/var/www/bin/console"]
