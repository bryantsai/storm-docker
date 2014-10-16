FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN apt-get update \
 && apt-get install -y openjdk-7-jre-headless \
 && apt-get install -y supervisor \
 && echo [supervisord] | tee -a /etc/supervisor/supervisord.conf \
 && echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf \
 && rm -rf /var/lib/apt/lists/*

ENV ZOOKEEPER_HOME /usr/share/zookeeper

RUN apt-get update \
 && apt-get install -y zookeeper=3.4.* zookeeperd=3.4.* \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s $ZOOKEEPER_HOME/bin/zkEnv.sh /usr/bin/zkEnv.sh \
 && ln -s $ZOOKEEPER_HOME/bin/zkServer.sh /usr/bin/zkServer.sh \
 && echo autopurge.purgeInterval=24 | tee -a /etc/zookeeper/conf/zoo.cfg \
 && echo autopurge.snapRetainCount=5 | tee -a /etc/zookeeper/conf/zoo.cfg

ADD start-zookeeper.sh /usr/bin/start-zookeeper.sh

# (client leader leader.eletion)
EXPOSE 2181 2888 3888

ENTRYPOINT ["/usr/bin/start-zookeeper.sh"]
CMD []
