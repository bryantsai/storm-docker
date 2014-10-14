#!/bin/bash

id=$(($1))
cnt=$(($2))
if [[ id -gt 0 ]] && [[ cnt -gt 0 ]] && [[ id -le cnt ]] && ! [ -z "$DOCKER_HOST" ]; then
  echo $id > /var/lib/zookeeper/myid

  host=`echo $DOCKER_HOST|awk -F '://' '{print $2}'|awk -F ':' '{print $1}'`
  for i in `seq 1 $cnt`; do
    echo server.$i=$host:$((2888 - 1 + $i)):$((3888 - 1 + $i)) | tee -a /etc/zookeeper/conf/zoo.cfg
  done    
fi

echo [program:zookeerper] | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo command=zkServer.sh start-foreground | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo directory=/var/lib/zookeeper | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo autorestart=true | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo user=root | tee -a /etc/supervisor/conf.d/zookeerper.conf
supervisord -c /etc/supervisor/supervisord.conf
