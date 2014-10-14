#!/bin/bash

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

IP=`hostname -i`
[[ ! -z "$NIMBUS_PORT_6627_TCP_ADDR" ]] && IP=$NIMBUS_PORT_6627_TCP_ADDR

sed -i -e "s/%zookeeper%/$ZKADDR/g" $STORM_HOME/conf/storm.yaml
sed -i -e "s/%nimbus%/$IP/g" $STORM_HOME/conf/storm.yaml

n=0
if [[ -z "$@" ]]
then
  /bin/bash
else
  for arg in "$@"; do
    case $arg in
      nimbus | drpc | supervisor | logviewer | ui )
        echo [program:storm-$arg] | tee -a /etc/supervisor/conf.d/storm-$arg.conf
        echo command=storm $arg | tee -a /etc/supervisor/conf.d/storm-$arg.conf
        echo directory=/home/storm | tee -a /etc/supervisor/conf.d/storm-$arg.conf
        echo autorestart=true | tee -a /etc/supervisor/conf.d/storm-$arg.conf
        echo user=storm | tee -a /etc/supervisor/conf.d/storm-$arg.conf
        n=$(( $n + 1 ))
        ;;
      * ) ;;
    esac
  done

  if [[ $n -gt 0 ]]; then
    supervisord -c /etc/supervisor/supervisord.conf
  else
    /bin/bash
  fi
fi
