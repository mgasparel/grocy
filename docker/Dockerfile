FROM alpine:3.21

RUN apk add --no-cache \
	nginx \
	supervisor \
	php83 \
	php83-fpm \
	php83-ctype \
	php83-curl \
	php83-fileinfo \
	php83-gd \
	php83-gettext \
	php83-iconv \
	php83-intl \
	php83-ldap \
	php83-mbstring \
	php83-opcache \
	php83-openssl \
	php83-pdo \
	php83-pdo_sqlite \
	# sqlite CLI is used by entrypoint bootstrap for initial SQL migrations
	sqlite \
	php83-phar \
	php83-session \
	php83-simplexml \
	php83-tokenizer \
	php83-xml \
	php83-xmlwriter \
	php83-zip \
	# gettext is required for Grocy translations
	tzdata \
	&& mkdir -p /run/nginx /app/www /config \
	&& sed -E -i 's/^;?clear_env\s*=.*$/clear_env = no/' /etc/php83/php-fpm.d/www.conf \
	&& sed -E -i 's|^;?daemonize\s*=.*$|daemonize = no|' /etc/php83/php-fpm.conf

COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY docker/php-fpm/www.conf /etc/php83/php-fpm.d/www.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /app/www
EXPOSE 80
ENV GROCY_DATAPATH=/config/data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
