FROM debian:buster

RUN	 apt-get clean && apt-get update
RUN	 apt-get install -qy nginx php-fpm php-mysqli mariadb-server wget unzip openssl
RUN	 wget 	https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip && \
	 unzip -q phpMyAdmin-5.0.4-all-languages.zip && \
	 mv phpMyAdmin-5.0.4-all-languages/ /var/www/phpmyadmin/ && \
	 rm -rf phpMyAdmin-5.0.4-all-languages/ && \
	 rm phpMyAdmin-5.0.4-all-languages.zip
RUN	 wget wordpress.org/latest.tar.gz && \
	 tar -xf latest.tar.gz && \
	 mv wordpress/ /var/www && \
	 rm latest.tar.gz
RUN	 openssl req -new -x509 -days 365 -newkey rsa:4096 -keyout localhost.key -out localhost.crt -nodes -subj "/C=RU" && \
	 mv localhost.crt /etc/ssl/certs/ && \
	 mv localhost.key /etc/ssl/private/
COPY srcs/nginx.conf-on /etc/nginx
COPY srcs/nginx.conf-off /etc/nginx
RUN  cp /etc/nginx/nginx.conf-on /etc/nginx/nginx.conf
COPY srcs/autoindexoff.sh /
COPY srcs/autoindexon.sh /
COPY srcs/wp-config.php var/www/wordpress
CMD	 service mysql start && \
	 mysql -e "create database if not exists ft_wp;" && \
	 mysql -e "grant all on ft_wp.* to 'admin' identified by 'admin';" && \
	 service php7.3-fpm start && \
	 nginx && bash
