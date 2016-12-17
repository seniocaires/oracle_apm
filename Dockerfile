FROM debian:jessie

MAINTAINER Senio Caires <seniocaires@gmail.com>

# --------------------
# JAVA
# --------------------

# Add webupd8 repository
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && apt-get update \

# Java install
    && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default \

# Clear
    && rm -rf /var/cache/oracle-jdk8-installer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --------------------
# WILDFLY
# --------------------

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y wget zip \
    && wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip \
    && unzip wildfly-10.1.0.Final.zip \
    && rm wildfly-10.1.0.Final.zip

# ----------------
# ORACLE AGENT
# ----------------

ADD oracle /opt/oracle

ENV STAGE_DIR /tmp/apm_staging
ENV AGENT_REGISTRATION_KEY RSLoPr-pGrNYfmz3bkWf_FW54v
ENV JBOSS_HOME /opt/wildfly-10.1.0.Final

RUN apt-get install -y dnsutils curl bc \
    && cd /opt/oracle && tar -vzxf AgentInstall.tar.gz \
    && cd /opt/oracle/AgentInstall \
    && ./AgentInstall.sh AGENT_TYPE=apm_java_as_agent \
       STAGE_LOCATION=${STAGE_DIR} \
       AGENT_REGISTRATION_KEY=${AGENT_REGISTRATION_KEY} \
    && cd ${STAGE_DIR} && chmod +x ProvisionApmJavaAsAgent.sh \
    && ./ProvisionApmJavaAsAgent.sh -d ${JBOSS_HOME} -no-wallet


EXPOSE 8080
ENTRYPOINT ["/bin/bash", "-c", "/opt/wildfly-10.1.0.Final/bin/standalone.sh -b 0.0.0.0 && tail -f /dev/null"]
