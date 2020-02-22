FROM ubuntu:bionic
LABEL "Maintainer"="Ricardo Barbosa"
LABEL "e-mail"="rickkbarbosa@live.com"
LABEL "Description"="Nagios on Docker" 
LABEL "version"="0.2.1"

USER root
WORKDIR /tmp

#Declare variables
ENV PERL_MM_USE_DEFAULT 1
ENV DEBIAN_FRONTEND noninteractive
ENV NAGIOSUSER admin
ENV NAGIOSPASS nagios

#Generate locales
RUN apt update && apt install -y locales
RUN locale-gen en_US.UTF-8 pt_BR.UTF-8 es_AR.UTF-8
RUN update-locale

#Initial Packages
RUN apt install -y \
    build-essential \
    curl \
    dh-make-perl \
    libpcre3-dev \
    nagios-nrpe-plugin \
    nagios-plugins \
    nagios-snmp-plugins \
    nagios3 \
    libapache2-mod-php \
    librrds-perl \
    nmap \
    perl \
    php-dev \
    php-curl \
    php-gd \
    rrdtool \
    telnet \
    wget

RUN apt install -y \
    php-apcu \
    php-pear

RUN cpan install install Filter::Simple
RUN cpan install install Logger::Syslog
RUN cpan install DBI

#PNP4Nagios
RUN wget http://downloads.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.26.tar.gz
RUN tar xfz pnp4nagios-0.6.26.tar.gz -C /tmp/

WORKDIR /tmp/pnp4nagios-0.6.26
RUN mkdir -p /var/lib/nagios3/perfdata && \
    chown -R nagios: /var/lib/nagios3/perfdata
RUN cd /tmp/pnp4nagios-0.6.26 && \
    ./configure --with-httpd-conf=/etc/apache2/conf-enabled && \
    make all && \
	make install && \
	make install-webconf && \
	make install-config && \
	make install-init

RUN sed -i 's/AuthUserFile.*/AuthUserFile \/etc\/nagios3\/htpasswd.users/g' /etc/apache2/conf-enabled/pnp4nagios.conf && \
    a2enmod rewrite

#Creating user
#RUN htpasswd -b -c /etc/nagios3/htpasswd.users ${NAGIOSUSER} ${NAGIOSPASS}
RUN htpasswd -b -c /etc/nagios3/htpasswd.users nagiosadmin ${NAGIOSPASS}
#RUN find /etc/nagios3 -type f -exec sed -i "s/nagiosadmin/${NAGIOSUSER}/g" {} \;


EXPOSE 80 443 5666 

#COPY nginx.conf /etc/nginx/sites-enabled/nagios.conf
#COPY apache2.conf /etc/apache2/conf-enabled/nagios3.conf
COPY xtras/ /tmp/xtras
RUN cp -r /tmp/xtras/nagios/* /etc/nagios3/
RUN cp -r /tmp/xtras/pnp4nagios/* /usr/local/pnp4nagios/share/application/models/data.php

#Garbage collector
RUN rm -fr /tmp/xtras \
    /tmp/pnp4nagios* \
    /usr/local/pnp4nagios/share/install.php

COPY init_nagios.sh /root/init_nagios.sh
RUN chmod +x /root/init_nagios.sh
CMD ["/bin/bash", "/root/init_nagios.sh"]