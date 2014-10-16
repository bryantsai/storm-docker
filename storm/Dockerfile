FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN apt-get update \
 && apt-get install -y openjdk-7-jre-headless \
 && apt-get install -y supervisor \
 && echo [supervisord] | tee -a /etc/supervisor/supervisord.conf \
 && echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf \
 && rm -rf /var/lib/apt/lists/*

ENV STORM_HOME /usr/share/storm
ENV STORM_VERSION 0.9.2-incubating
ENV STORM_DOWNLOAD_URL http://apache.claz.org/incubator/storm/apache-storm-0.9.2-incubating/apache-storm-0.9.2-incubating.tar.gz

RUN apt-get update \
 && apt-get install -y curl \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sSL "$STORM_DOWNLOAD_URL" -o storm.tgz \
 && tar xfz storm.tgz -C /usr/share \
 && rm storm.tgz \
 && groupadd storm \
 && useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm \
 && mkdir /var/log/storm \
 && chown -R storm:storm /var/log/storm \
 && ln -s /usr/share/apache-storm-$STORM_VERSION $STORM_HOME \
 && ln -s $STORM_HOME/bin/storm /usr/bin/storm

ADD storm.yaml $STORM_HOME/conf/storm.yaml
ADD cluster.xml $STORM_HOME/logback/cluster.xml
ADD start-storm.sh /usr/bin/start-storm.sh 

VOLUME ["/var/log/storm"]

# nimbus (thrift drpc drpc.invocations)
EXPOSE 6627 3772 3773
# supervisor (slot logviewer)
EXPOSE 6700 8000
# ui
EXPOSE 8080

ENTRYPOINT ["/usr/bin/start-storm.sh"]
CMD []
