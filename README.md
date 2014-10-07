# Storm on Docker

Storm clustering environment on Docker, ZooKeeper and Kafka included. The quickest and easiest way of getting Storm cluster up and running, ready for submmiting your topologies.

This work is based on https://github.com/wurstmeister/storm-docker and https://github.com/wurstmeister/kafka-docker. Kudos to wurstmeister.

**Note the Docker version used to was 1.2.0. Storm version used was 0.9.2.**

## TL;DR

First you need [Docker](https://docker.com/) and [Fig](http://orchardup.github.io/fig/index.html) installed.

Then simply run to launch a Storm cluster, along with a single ZooKeeper instance and a signle Kafka instace:

```
$ fig up -d
Creating stormdocker_zookeeper_1...
Creating stormdocker_nimbus_1...
Creating stormdocker_ui_1...
Creating stormdocker_supervisor_1...
Creating stormdocker_kafka_1...

$ fig ps
          Name                   Command          State                                  Ports
----------------------------------------------------------------------------------------------------------------------------
stormdocker_zookeeper_1                           Up       3888/tcp, 2888/tcp, 2181/tcp
stormdocker_nimbus_1       nimbus drpc            Up       8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 8000/tcp, 6700/tcp
stormdocker_ui_1           ui                     Up       48080->8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 8000/tcp, 6700/tcp
stormdocker_supervisor_1   supervisor logviewer   Up       8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 49159->8000/tcp, 6700/tcp
stormdocker_kafka_1                               Up       9092/tcp
```

This is a complete self-contained environment, only Storm UI port and Supervior logviewer port are exposed so that we can access them externally from browsers. Also, all of ZooKeeper, Storm, and Kafka processes are managed by "supervisord".

You can easily scale up Storm Supervisors and Kafka instances easily with fig:

```
$ fig scale supervisor=2 kafka=4
Starting stormdocker_supervisor_2...
Starting stormdocker_kafka_2...
Starting stormdocker_kafka_3...
Starting stormdocker_kafka_4...

$ fig ps
          Name                   Command          State                                                 Ports
----------------------------------------------------------------------------------------------------------------------------------------------------------
stormdocker_zookeeper_1                           Up       3888/tcp, 2888/tcp, 2181/tcp
stormdocker_nimbus_1       nimbus drpc            Up       8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 8000/tcp, 6700/tcp
stormdocker_ui_1           ui                     Up       48080->8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 8000/tcp, 6700/tcp
stormdocker_supervisor_2   supervisor logviewer   Up       8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 49160->8000/tcp, 6700/tcp
stormdocker_supervisor_1   supervisor logviewer   Up       8080/tcp, 3773/tcp, 3772/tcp, 6627/tcp, 49159->8000/tcp, 6700/tcp
stormdocker_kafka_4                               Up       9092/tcp
stormdocker_kafka_3                               Up       9092/tcp
stormdocker_kafka_2                               Up       9092/tcp
stormdocker_kafka_1                               Up       9092/tcp
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

Note that by default a volume of current directory is mounted on `/code`. If you'd like to change it to map other directory, simply modify `fig.yml` to change the volumes of service "cli".

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

Currently only single ZooKeeper instance is supported. Multiple-instance cluster would be nice to add next.

## Storm

* Nimbus: single instance. It also contains DRPC server.
* Supervisor: single instance, but with fig you can freely scale it up or down.
* UI: single instance, with 8080 port exposed to as 48080.

## Kafka 

When fig brings up the cluster, there's only one Kafka broker. But it is dead simple to add more brokers with fig.
