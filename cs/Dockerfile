FROM bellsoft/liberica-openjdk-debian:11.0.14.1-1

RUN apt-get update \
&& apt-get install -yq \
      curl \
      sudo \ 
      nano \ 
      gawk \
      mc   \
      procps \
      net-tools \
&& rm -rf /var/lib/apt/lists/* 

COPY ./distr /tmp/1c_cs

RUN cd /tmp/1c_cs/ \
  && tar xzf 1c_cs_27.0.34_linux_x86_64.tar.gz -C /tmp/1c_cs/ \
  && rm -rf 1c_cs_27.0.34_linux_x86_64.tar.gz \
  && chmod +x ./1ce-installer-cli \
  && ./1ce-installer-cli install \
  && chmod +x /opt/1C/1CE/components/1c-enterprise-ring-0.19.5+12-x86_64/ring

ENV PATH /opt/1C/1CE/components/1c-enterprise-ring-0.19.5+12-x86_64:/usr/lib/jvm/jdk-11.0.14.1-bellsoft-x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#cs
RUN mkdir -p /var/cs/cs_instance
#elastic
RUN mkdir -p /var/cs/elastic_instance 
#hazelcast
RUN mkdir -p /var/cs/hc_instance

RUN mv /bin/pidof /bin/_pidof && cp /bin/echo /bin/pidof 

USER root

# Создать инстанс
RUN sudo useradd cs_user \
  #&& sudo chown cs_user:cs_user /var/cs/cs_instance \ 
  && ring cs instance create --dir /var/cs/cs_instance --owner root \
  && ring cs --instance cs_instance service create --username root --stopped

# Настроить cs на работу с компонентами из других контейнеров
    # "внешний" hazelcast
RUN ring cs --instance cs_instance hazelcast set-params --group-name 1ce-cs --group-password cs-pass --addresses localhost\
    # "внешний" elasticsearch
    && ring cs --instance cs_instance elasticsearch set-params --addresses localhost:9300\
    # "внешний" db
    && ring cs --instance cs_instance jdbc pools --name common set-params --url jdbc:postgresql://postgres:5432/cs?currentSchema=public\
    && ring cs --instance cs_instance jdbc pools --name common set-params --username postgres\
    && ring cs --instance cs_instance jdbc pools --name common set-params --password postgres\
    && ring cs --instance cs_instance jdbc pools --name privileged set-params --url jdbc:postgresql://postgres:5432/cs?currentSchema=public\
    && ring cs --instance cs_instance jdbc pools --name privileged set-params --username postgres\
    && ring cs --instance cs_instance jdbc pools --name privileged set-params --password postgres
    # WebSocket
   # && ring cs --instance cs_instance websocket set-params --hostname localhost \
    # порт не 8087, т.к. это административный интерфейс
   # && ring cs --instance cs_instance websocket set-params --port 8085    

#elastic
RUN sudo useradd elasticsearch \ 
  && sudo chown elasticsearch:elasticsearch /var/cs/elastic_instance \
  && ring elasticsearch instance create --dir /var/cs/elastic_instance --owner elasticsearch \
  && ring elasticsearch --instance elastic_instance service create --username elasticsearch --stopped

#hazelcast
RUN sudo useradd hc_user \
  #&& sudo chown hc_user:hc_user /var/cs/hc_instance \
  && ring hazelcast instance create --dir /var/cs/hc_instance --owner root \
  && ring hazelcast --instance hc_instance service create --username root --stopped

COPY ./scripts/start.sh /opt
RUN chmod +x /opt/start.sh

EXPOSE 9094

ENTRYPOINT ["/opt/start.sh"]
