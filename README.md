# Storm on Docker

Storm clustering environment on Docker, ZooKeeper and Kafka included. The quickest and easiest way of getting Storm cluster up and running, ready for submmiting your topologies.

This work is based on https://github.com/wurstmeister/storm-docker and https://github.com/wurstmeister/kafka-docker. Kudos to wurstmeister.

**Note the Docker version used to was 1.3.0, Storm version used was 0.9.2, Kafka version used was 0.8.1.1 (SCALA 2.9.2), ZooKeeper version used was 3.4.5.**

## TL;DR

First you need [Docker](https://docker.com/) and [Fig](http://orchardup.github.io/fig/index.html) installed.

Then simply run to launch a Storm cluster, along with a single ZooKeeper instance and a signle Kafka instace:

```
$ fig up -d
Creating stormdocker_syslog_1...
Creating stormdocker_zookeeper_1...
Creating stormdocker_kafka_1...
Creating stormdocker_kafkacli_1...
Creating stormdocker_nimbus_1...
Creating stormdocker_cli_1...
Creating stormdocker_supervisor_1...
Creating stormdocker_ui_1...

$ fig ps
          Name                        Command               State                                      Ports
----------------------------------------------------------------------------------------------------------------------------------------------
stormdocker_cli_1          /usr/bin/start-storm.sh cli      Exit 0
stormdocker_kafka_1        /usr/bin/start-kafka.sh          Up       9092/tcp
stormdocker_kafkacli_1     /usr/bin/start-kafka.sh cli      Exit 0
stormdocker_nimbus_1       /usr/bin/start-storm.sh ni ...   Up       3772/tcp, 3773/tcp, 0.0.0.0:46627->6627/tcp, 6700/tcp, 8000/tcp, 8080/tcp
stormdocker_supervisor_1   /usr/bin/start-storm.sh su ...   Up       3772/tcp, 3773/tcp, 6627/tcp, 6700/tcp, 0.0.0.0:49167->8000/tcp, 8080/tcp
stormdocker_syslog_1       rsyslogd -n                      Up       514/tcp, 514/udp
stormdocker_ui_1           /usr/bin/start-storm.sh ui       Up       3772/tcp, 3773/tcp, 6627/tcp, 6700/tcp, 8000/tcp, 0.0.0.0:48080->8080/tcp
stormdocker_zookeeper_1    /usr/bin/start-zookeeper.sh      Up       0.0.0.0:42181->2181/tcp, 2888/tcp, 3888/tcp
```

This is a complete self-contained environment, with Storm UI port and Supervior logviewer port exposed so that we can access them externally from browsers. Also, ZooKeeper client port and Storm Nimbus Thrift port are exposed so that you can access ZooKeeper or submit Strom topologies from outside.

All of ZooKeeper, Storm, and Kafka processes are managed by "supervisord".

You can easily scale up Storm Supervisors and Kafka instances easily with fig:

```
$ fig scale supervisor=2 kafka=4
Starting stormdocker_supervisor_2...
Starting stormdocker_kafka_2...
Starting stormdocker_kafka_3...
Starting stormdocker_kafka_4...

$ fig ps
          Name                        Command               State                                      Ports
----------------------------------------------------------------------------------------------------------------------------------------------
stormdocker_cli_1          /usr/bin/start-storm.sh cli      Exit 0
stormdocker_kafka_1        /usr/bin/start-kafka.sh          Up       9092/tcp
stormdocker_kafka_2        /usr/bin/start-kafka.sh          Up       9092/tcp
stormdocker_kafka_3        /usr/bin/start-kafka.sh          Up       9092/tcp
stormdocker_kafka_4        /usr/bin/start-kafka.sh          Up       9092/tcp
stormdocker_kafkacli_1     /usr/bin/start-kafka.sh cli      Exit 0
stormdocker_nimbus_1       /usr/bin/start-storm.sh ni ...   Up       3772/tcp, 3773/tcp, 0.0.0.0:46627->6627/tcp, 6700/tcp, 8000/tcp, 8080/tcp
stormdocker_supervisor_1   /usr/bin/start-storm.sh su ...   Up       3772/tcp, 3773/tcp, 6627/tcp, 6700/tcp, 0.0.0.0:49167->8000/tcp, 8080/tcp
stormdocker_supervisor_2   /usr/bin/start-storm.sh su ...   Up       3772/tcp, 3773/tcp, 6627/tcp, 6700/tcp, 0.0.0.0:49168->8000/tcp, 8080/tcp
stormdocker_syslog_1       rsyslogd -n                      Up       514/tcp, 514/udp
stormdocker_ui_1           /usr/bin/start-storm.sh ui       Up       3772/tcp, 3773/tcp, 6627/tcp, 6700/tcp, 8000/tcp, 0.0.0.0:48080->8080/tcp
stormdocker_zookeeper_1    /usr/bin/start-zookeeper.sh      Up       0.0.0.0:42181->2181/tcp, 2888/tcp, 3888/tcp
```

Accessing Storm command, say submitting a topology, is also a simple matter:

```
$ fig run --rm cli

root@cli:/code# storm version
0.9.2-incubating

root@cli:/code# ls -l
total 40
-rw-r--r-- 1 root root 4972 Oct  2 14:13 README.md
-rw-r--r-- 1 root root  930 Oct  2 12:46 fig.yml
drwxr-xr-x 1 root root  136 Oct  2 12:46 kafka
drwxr-xr-x 1 root root  204 Oct  2 12:46 storm
drwxr-xr-x 1 root root  136 Oct  2 12:46 zookeeper
```

Note that by default a volume of current directory is mounted on `/code`. If you'd like to change it to map other directory, simply modify `fig.yml` to change the volumes of service "cli". Also, since Nimbus Thrift port is exposed, you can also submit topologies from the outside.

You can also access Kafka command line in the same manner:

```
$ fig run --rm kafkacli

# create a topic
root@kafkacli:/code# kafka-topics.sh --create --topic topic --partition 4 --replication 2 --zookeeper $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT

# inspect the topic created
root@kafkacli:/code# kafka-topics.sh --list --topic topic --zookeeper $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT

# start a producer
root@kafkacli:/code# kafka-console-producer.sh --topic topic --sync --broker-list=$KAFKA_PORT_9092_TCP_ADDR:$KAFKA_PORT_9092_TCP_PORT

# start a consumer
root@kafkacli:/code# kafka-console-consumer.sh --topic topic --zookeeper $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT
```

To view the output of containers:

```
$ fig logs
```

To bring the environment down:

```
fig stop
```

Optionally to remove all stopped services:

```
fig rm
```

That should be it! The rest of this document is only for the interested souls.

## ZooKeeper

By default a single ZooKeeper instance cluster is used. You have the choice to use multi-instance ZooKeeper cluster by specifying different fig yml file. There are another two provided already: 3-instance and 5-instance. You can of course create one if you need larger cluster. Change to use a 5-instance ZooKeeper cluster is dead easy:

```
$ fig -f fig-5zk.yml up -d
Creating stormdocker_zookeeper4_1...
Creating stormdocker_zookeeper5_1...
Creating stormdocker_zookeeper1_1...
Creating stormdocker_zookeeper2_1...
Creating stormdocker_zookeeper3_1...
Creating stormdocker_kafka_1...
Creating stormdocker_nimbus_1...
Creating stormdocker_ui_1...
Creating stormdocker_supervisor_1...
```

Notice that you have to specify `-f` in all fig commands against the right set, otherwise things might messed up. It is advised to rename the selected one to be `fig.yml` to make the operation easier.

## Storm

* Nimbus: single instance. It also contains DRPC server.
* Supervisor: single instance, but with fig you can freely scale it up or down.
* UI: single instance, with 8080 port exposed to as 48080.

## Kafka 

When fig brings up the cluster, there's only one Kafka broker. But it is dead simple to add more brokers with fig.
