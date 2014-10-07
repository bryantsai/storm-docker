FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV STORM_HOME /usr/share/apache-storm-0.9.2-incubating

RUN apt-get update && apt-get install -y openjdk-7-jre-headless
RUN apt-get install -y supervisor unzip wget
RUN wget -q -N http://apache.claz.org/incubator/storm/apache-storm-0.9.2-incubating/apache-storm-0.9.2-incubating.zip; unzip -o apache-storm-0.9.2-incubating.zip -d /usr/share/; rm apache-storm-0.9.2-incubating.zip

ADD storm.yaml $STORM_HOME/conf/storm.yaml
ADD cluster.xml $STORM_HOME/logback/cluster.xml
ADD start-storm.sh /usr/bin/start-storm.sh 

RUN groupadd storm; useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm; mkdir /var/log/storm; chown -R storm:storm /var/log/storm; ln -s /usr/share/apache-storm-0.9.2-incubating /usr/share/storm; ln -s /usr/share/apache-storm-0.9.2-incubating/bin/storm /usr/bin/storm

RUN echo [supervisord] | tee -a /etc/supervisor/supervisord.conf ; echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf

# nimbus (thrift drpc drpc.invocations)
EXPOSE 6627 3772 3773
# supervisor (slot logviewer)
EXPOSE 6700 8000
# ui
EXPOSE 8080

ENTRYPOINT ["/usr/bin/start-storm.sh"]
CMD []
