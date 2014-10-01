#!/bin/bash
BROKERS=$1
PORT=$2
HOST_IP=$3
[[ -z "$BROKERS" ]] && BROKERS=1
[[ -z "$PORT" ]] && PORT=9092
[[ -z "$HOST_IP" ]] && HOST_IP=`echo $DOCKER_HOST|awk -F '://' '{print $2}'|awk -F ':' '{print $1}'`
#[[ -z "$HOST_IP" ]] && HOST_IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1`

ID=1
while [ $ID -le $BROKERS ]
do
  docker run -p $PORT:$PORT -h kafka$ID --name kafka$ID --link zookeeper:zk -e BROKER_ID=$ID -e HOST_IP=$HOST_IP -e PORT=$PORT -d wurstmeister/kafka
  PORT=$(($PORT+1))
  ID=$(($ID+1))
done
