#!/bin/bash

export PATH=$PATH:$KAFKA_HOME/bin

BROKER_ID=$1
if [ "$BROKER_ID" == "cli" ] || ! [ -z $BROKER_ID ] && [[ ! $BROKER_ID =~ ^[0-9]+$ ]]; then
  /bin/bash
  exit 0
elif [ -z $BROKER_ID ]; then
  ZKNAME=$ZK_NAME
  [[ ! -z "$ZK1_NAME" ]] && ZKNAME=$ZK1_NAME
  BROKER_ID=`echo $ZKNAME|awk -F '/' '{print $2}'|awk -F '_' '{print $(NF)}'`
  if [[ ! $BROKER_ID =~ ^[0-9]+$ ]]; then
    /bin/bash
    exit 0
  fi
fi

HOST_IP=`hostname -i`
[[ ! -z "$DOCKER_HOST" ]] && HOST_IP=`echo $DOCKER_HOST|awk -F '://' '{print $2}'|awk -F ':' '{print $1}'`

ZKINST=$(($ZK_INSTANCES))
if [[ ZKINST -gt 0 ]]; then
  for i in `seq 1 $ZKINST`; do
    ZK=$'ZK'$i$'_PORT_2181_TCP_ADDR'
    if [[ -z "$ZKADDR" ]]; then
      [[ ! -z "${!ZK}" ]] && ZKADDR=${!ZK}
    else
      [[ ! -z "${!ZK}" ]] && ZKADDR=$ZKADDR$','${!ZK}
    fi
  done
else
  ZKADDR=$ZK_PORT_2181_TCP_ADDR
fi

sed -r -i "s/(broker.id)=(.*)/\1=$BROKER_ID/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/^(port)=(.*)/\1=9092/g" $KAFKA_HOME/config/server.properties
[[ ! -z "$HOST_IP" ]] && sed -r -i "s/#(advertised.host.name)=(.*)/\1=$HOST_IP/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/^(log.dirs)=(.*)/\1=\/var\/kafka/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZKADDR/g" $KAFKA_HOME/config/server.properties

if [ ! -z "$KAFKA_HEAP_OPTS"]; then
  sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
fi

echo [program:kafka] | tee -a /etc/supervisor/conf.d/kafka.conf
echo command=$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties | tee -a /etc/supervisor/conf.d/kafka.conf
echo autorestart=true | tee -a /etc/supervisor/conf.d/kafka.conf
echo stopasgroup=true | tee -a /etc/supervisor/conf.d/kafka.conf
echo user=root | tee -a /etc/supervisor/conf.d/kafka.conf
supervisord -c /etc/supervisor/supervisord.conf
