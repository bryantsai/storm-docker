FROM ubuntu:14.10
MAINTAINER bryantsai

RUN apt-get update \
 && apt-get install -y rsyslog \
 && rm -rf /var/lib/apt/lists/* \
 && echo "\$ModLoad imudp" >> /etc/rsyslog.conf \
 && echo "\$UDPServerRun 514" >> /etc/rsyslog.conf \
 && echo "\$ModLoad imtcp" >> /etc/rsyslog.conf \
 && echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf

VOLUME ["/dev", "/var/log"]

EXPOSE 514 514/udp

ENTRYPOINT ["rsyslogd"]
CMD ["-n"]
