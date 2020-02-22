#!/bin/bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
UPLOAD_FILES="/tmp/nagios3/{logs,perfdata}"

mkdir -p ${UPLOAD_FILES}

docker container rm -f nagios-server  1>/dev/null 2>&1

docker run -d \
  --net=host \
  --name nagios-server \
  --restart=always \
  -p 80:80 \
  -p 5666:5666 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/nagios3/perfdata:/usr/local/pnp4nagios/var/perfdata \
  -v /tmp/nagios3/logs:/var/log/nagios3 \
  nagios-server:latest
