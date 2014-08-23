# Version 0.0.1
FROM ubuntu:trusty
MAINTAINER Niklas Andersson <niklas.andersson@openforce.se>
ENV REFRESHED_AT 2014-08-11
# Refresh apt
RUN apt-get update -yqq
# Setup Apache2
RUN apt-get install -y apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /tmp
ENV APACHE_PID_FILE /tmp/apache2.pid
# GPG
ADD apt.pub /tmp/apt.pub
ADD apt.sec /tmp/apt.sec
RUN gpg --import /tmp/apt.pub
RUN gpg --import /tmp/apt.sec
RUN gpg --armour --export apt@openforce.org > /var/www/html/apt.key
# Reprepro
ENV REPREPRO_BASE_DIR /var/www/html
RUN apt-get install reprepro -y
RUN mkdir -p /var/www/html/{conf,dists,incoming,indices,logs,pool,project,tmp}
COPY distributions /var/www/html/conf/distributions
COPY options /var/www/html/conf/options
# Fetch debs and import them to repo
COPY debs/ /tmp/debs
RUN for a in /tmp/debs/*.deb; do reprepro includedeb trusty $a; done
EXPOSE 80
CMD /usr/sbin/apache2 -D FOREGROUND
