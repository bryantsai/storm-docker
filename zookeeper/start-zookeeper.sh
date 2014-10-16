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

echo "log4j.appender.SYSLOG=org.apache.log4j.net.SyslogAppender" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.Facility=USER" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.FacilityPrinting=false" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.Header=true" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.SyslogHost=$SYSLOG_PORT_514_UDP_ADDR:$SYSLOG_PORT_514_UDP_PORT" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.layout=org.apache.log4j.PatternLayout" >> /etc/zookeeper/conf/log4j.properties
echo "log4j.appender.SYSLOG.layout.ConversionPattern=[ level=%p thread=%t logger=%c | %m ]" >> /etc/zookeeper/conf/log4j.properties
sed -r -i "s/(ZOO_LOG4J_PROP)=(.*)/\1=INFO,SYSLOG,ROLLINGFILE/g" /etc/zookeeper/conf/environment

echo [program:zookeeper] | tee -a /etc/supervisor/conf.d/zookeeper.conf
echo command=zkServer.sh start-foreground | tee -a /etc/supervisor/conf.d/zookeeper.conf
echo directory=/var/lib/zookeeper | tee -a /etc/supervisor/conf.d/zookeeper.conf
echo autorestart=true | tee -a /etc/supervisor/conf.d/zookeeper.conf
echo user=root | tee -a /etc/supervisor/conf.d/zookeeper.conf
supervisord -c /etc/supervisor/supervisord.conf
