#!/bin/bash
/etc/init.d/nagios3 restart
/etc/init.d/npcd start
/usr/sbin/apache2ctl -k start

tail -f /var/log/apache2/access.log /var/log/apache/error.log