FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN apt-get update \
 && apt-get install -y openjdk-7-jre-headless \
 && apt-get install -y supervisor \
 && echo [supervisord] | tee -a /etc/supervisor/supervisord.conf \
 && echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf \
 && rm -rf /var/lib/apt/lists/*

ENV KAFKA_HOME /opt/kafka_2.9.2-0.8.1.1
ENV KAFKA_DOWNLOAD_URL http://mirror.symnds.com/software/Apache/kafka/0.8.1.1/kafka_2.9.2-0.8.1.1.tgz

RUN apt-get update \
 && apt-get install -y curl \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sSL "$KAFKA_DOWNLOAD_URL" -o kafka.tgz \
 && tar xfz kafka.tgz -C /opt \
 && rm kafka.tgz

ADD start-kafka.sh /usr/bin/start-kafka.sh

VOLUME ["/var/kafka"]

EXPOSE 9092

ENTRYPOINT ["/usr/bin/start-kafka.sh"]
CMD []
