FROM ubuntu:latest

RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get -y install curl python3.7 git \
    && curl -L https://bootstrap.saltstack.com -o install_salt.sh \
    && sh install_salt.sh -P

COPY ./top.sls /srv/salt/

RUN git clone https://github.com/bearddan2000/saltstack-lib-pillars.git \
    && chmod -R +x saltstack-lib-pillars \
    && cp saltstack-lib-pillars/masterless.conf /etc/salt/minion.d \
    && cp saltstack-lib-pillars/lang/scala.sls /srv/salt \
    && rm -Rf saltstack-lib-pillars

RUN service salt-minion stop \
    && salt-call --local state.highstate

COPY bin/ .

RUN chmod +x ./ScalaMain.scala \
    && scalac ./ScalaMain.scala \
    && chmod +x ./ScalaMain.class

CMD ["scala", "-classpath", "./", "ScalaMain"]
