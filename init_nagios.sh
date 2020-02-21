#!/bin/bash
/etc/init.d/nagios3 restart
/usr/sbin/apache2ctl -k start
tail -f /var/log/apache2/access.log /var/log/apache/error.log