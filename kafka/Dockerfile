FROM ubuntu:14.10
MAINTAINER bryantsai

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV KAFKA_HOME /opt/kafka_2.9.2-0.8.1.1

RUN apt-get update && apt-get install -y openjdk-7-jre-headless
RUN apt-get install -y supervisor wget
RUN wget -q -N http://mirror.symnds.com/software/Apache/kafka/0.8.1.1/kafka_2.9.2-0.8.1.1.tgz; tar xfz kafka_2.9.2-0.8.1.1.tgz -C /opt; rm kafka_2.9.2-0.8.1.1.tgz

ADD start-kafka.sh /usr/bin/start-kafka.sh 

RUN echo [supervisord] | tee -a /etc/supervisor/supervisord.conf ; echo nodaemon=true | tee -a /etc/supervisor/supervisord.conf

VOLUME ["/var/kafka"]

EXPOSE 9092

ENTRYPOINT ["/usr/bin/start-kafka.sh"]
CMD []
