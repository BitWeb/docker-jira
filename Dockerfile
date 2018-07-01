FROM bitweb/java:8
MAINTAINER BitWeb

# JIRA variables
ENV JIRA_HOME              /var/atlassian/jira
ENV JIRA_INSTALL           /opt/atlassian/jira
ENV JIRA_VERSION           7.10.2
ENV DOWNLOAD_URL           https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz

# MySQL Connector
ENV CONNECTOR_VERSION      5.1.46
ENV CONNECTOR_DOWNLOAD_URL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${CONNECTOR_VERSION}.tar.gz

#################################################
####     No need to edit below this line     ####
#################################################

# Install JIRA dependencies
RUN apt-get update && apt-get -y install --no-install-recommends curl htop

# Install JIRA and helper tools and setup initial home directory structure
RUN mkdir -p          ${JIRA_HOME} \
    && mkdir -p       ${JIRA_HOME}/caches/indexes \
    && chmod -R 700   ${JIRA_HOME} \
    && mkdir -p       ${JIRA_INSTALL}/conf/Catalina \
    && curl -Ls       ${DOWNLOAD_URL} | tar -xz --directory ${JIRA_INSTALL} --strip-components=1 --no-same-owner \
    && curl -Ls       ${CONNECTOR_DOWNLOAD_URL} | tar -xz --directory ${JIRA_INSTALL}/lib --strip-components=1 --no-same-owner "mysql-connector-java-$CONNECTOR_VERSION/mysql-connector-java-$CONNECTOR_VERSION-bin.jar" \
    && chmod -R 700   ${JIRA_INSTALL}/conf \
    && chmod -R 700   ${JIRA_INSTALL}/logs \
    && chmod -R 700   ${JIRA_INSTALL}/temp \
    && chmod -R 700   ${JIRA_INSTALL}/work \
    && echo -e        "\njira.home=$JIRA_HOME" >> ${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties

# Set Catalina PID location
# Todo: Still does not fix the error with stop-jira.sh: $CATALINA_PID was set but the specified file does not exist. Is Tomcat running? Stop aborted.
RUN sed -i "1iCATALINA_PID=\"$JIRA_INSTALL/work/catalina.pid\"\nexport CATALINA_PID" ${JIRA_INSTALL}/bin/setenv.sh

# Set the default working directory as the installation directory.
WORKDIR $JIRA_INSTALL

# Expose default HTTP connector port.
EXPOSE 8080

# Startup
CMD ["./bin/start-jira.sh", "-fg"]
