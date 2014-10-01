FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN apt-get update && apt-get install -y openjdk-7-jre-headless
RUN apt-get install -y supervisor
RUN apt-get install -y zookeeper=3.4.* zookeeperd=3.4.*

ADD start-zookeeper.sh /usr/bin/start-zookeeper.sh 

RUN ln -s /usr/share/zookeeper/bin/zkEnv.sh /usr/bin/zkEnv.sh; ln -s /usr/share/zookeeper/bin/zkServer.sh /usr/bin/zkServer.sh

RUN echo autopurge.purgeInterval=24 | tee -a /etc/zookeeper/conf/zoo.cfg; echo autopurge.snapRetainCount=5 | tee -a /etc/zookeeper/conf/zoo.cfg
RUN echo [supervisord] | tee -a /etc/supervisor/supervisord.conf ; echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf

# (client leader leader.eletion)
EXPOSE 2181 2888 3888

ENTRYPOINT ["/usr/bin/start-zookeeper.sh"]
CMD []
