#!/bin/bash

id=$1
if ! [ -z $id ] && [[ $id =~ ^[123]$ ]]
then
  echo $id > /var/lib/zookeeper/myid
  echo server.1=zookeeper1:2888:3888 | tee -a /etc/zookeeper/conf/zoo.cfg
  echo server.2=zookeeper2:2888:3888 | tee -a /etc/zookeeper/conf/zoo.cfg
  echo server.3=zookeeper3:2888:3888 | tee -a /etc/zookeeper/conf/zoo.cfg
fi

echo [program:zookeerper] | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo command=zkServer.sh start-foreground | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo directory=/var/lib/zookeeper | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo autorestart=true | tee -a /etc/supervisor/conf.d/zookeerper.conf
echo user=root | tee -a /etc/supervisor/conf.d/zookeerper.conf
supervisord -c /etc/supervisor/supervisord.conf
