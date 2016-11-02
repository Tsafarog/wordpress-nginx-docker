############################################################
# Dockerfile to build Centos-LEMP installed  Container
# Based on CentOS
############################################################

# Set the base image to Ubuntu
FROM centos:centos6.8

# File Author / Maintainer
MAINTAINER Urolime Technologies <devops@urolime.com>

# Add the ngix and PHP dependent repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo
ADD ./start.sh /start.sh
# Installing nginx 
RUN yum -y install nginx
RUN mkdir /var/log/php-fpm
RUN touch /var/log/php-fpm/php-fpm.log

# Installing PHP
RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum -y install nginx php-fpm php-cli php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-magickwand php-magpierss php-mbstring php-mcrypt php-mssql php-shout php-snmp php-soap php-tidy php-apc pwgen python-setuptools curl git tar net-tools exim  mailx; yum clean all


# Adding the configuration file of the nginx
RUN mkdir /system-config/
#ADD ./nginx.conf /system-config/nginx.conf
#ADD ./default.conf /system-config/default.conf
#ADD ./www.conf	/system-config/www.conf
#ADD ./php.ini	/system-config/php.ini
ADD  ./system-config /system-config
RUN mkdir /usr/share/nginx/system-config
RUN cp -rf /system-config/* /usr/share/nginx/system-config/
RUN rm -f /etc/nginx/nginx.conf
RUN rm -f /etc/php.ini
RUN rm -f /etc/php-fpm.d/www.conf
RUN rm -f /etc/php-fpm.conf
RUN rm -f /etc/nginx/conf.d/default.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /usr/share/nginx/system-config/nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /usr/share/nginx/system-config/php.ini /etc/php.ini
RUN ln -sf /usr/share/nginx/system-config/php-fpm.conf /etc/php-fpm.conf
RUN ln -sf /usr/share/nginx/system-config/www.conf /etc/php-fpm.d/www.conf
RUN ln -sf /usr/share/nginx/system-config/default.conf /etc/nginx/conf.d/default.conf
# Adding the configuration file of the Supervisor
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf


# Setup Wordpress
RUN rm -rf /usr/share/nginx/html
ADD http://wordpress.org/latest.tar.gz /wordpress.tar.gz
RUN tar xzf /wordpress.tar.gz
RUN cp -rf  /wordpress /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/

#Copy SSL Certficates
#COPY ./domain.* /system-config/

# Set the port to 80 
EXPOSE 80 443

# Add Entrypoint
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN mkdir /var/run/sshd

WORKDIR /usr/share/nginx/html
VOLUME ["/usr/share/nginx"]
#ENTRYPOINT ["exim"]
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["-bd"]
#Start Nginx 
#CMD ["nginx"]
CMD ["/bin/bash", "/start.sh"]
