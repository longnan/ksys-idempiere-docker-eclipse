#
# iDempiere-KSYS Dockerfile of Running iDempiere in Eclipse OSGi
#
# https://github.com/longnan/ksys-idempiere-docker-eclipse
#

FROM phusion/baseimage:0.9.19
MAINTAINER Ken Longnan <ken.longnan@gmail.com>

# Make default locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Setup proxy if needed
#ENV http_proxy http://10.0.0.12:8087/
#ENV https_proxy http://10.0.0.12:8087/
#RUN export http_proxy=$http_proxy
#RUN export https_proxy=$https_proxy

# Setup fast apt in China
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse \n" \
		 "deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse \n" \
	     "deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse \n" \
		 "deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse \n" \
         "deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse \n" \
		 "deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse \n" > /etc/apt/sources.list		 


# Add ksys folder
ADD ksys /tmp/ksys
		 
# Install oracle JDK 8 (offline model)
ENV JDK8_FILE jdk-8u102-linux-x64.tar.gz
RUN mkdir -p /usr/lib/jvm/jdk1.8.0/;
RUN tar --strip-components=1 -C /usr/lib/jvm/jdk1.8.0 -xzvf /tmp/ksys/$JDK8_FILE;
RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0/bin/java" 1
RUN update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac" 1
RUN update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0/bin/javaws" 1
RUN java -version
RUN rm /tmp/ksys/$JDK8_FILE

# Setup JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/jdk1.8.0/
ENV PATH $JAVA_HOME/bin:$PATH
# Minimum memory for the JVM
#ENV JAVA_MIN_MEM 256M
# Maximum memory for the JVM
#ENV JAVA_MAX_MEM 1024M
# Minimum perm memory for the JVM
#ENV JAVA_PERM_MEM 128M
# Maximum memory for the JVM
#ENV JAVA_MAX_PERM_MEM 256M

# Enabling SSH
RUN rm -f /etc/service/sshd/down
# Enabling the insecure key permanently. In production environments, you should use your own keys.
RUN /usr/sbin/enable_insecure_key

# Install unzip and other useful packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip pwgen expect

# Install iDempiere-KSYS Home
RUN unzip -d /opt /tmp/ksys/idempiereServer.gtk.linux.x86_64.zip
ENV IDEMPIERE_HOME /opt/idempiere.gtk.linux.x86_64/idempiere-server/
RUN rm /tmp/ksys/idempiereServer.gtk.linux.x86_64.zip

# Setup Environment for ksys-idempiere-server
RUN mv /tmp/ksys/idempiere.properties ${IDEMPIERE_HOME}/idempiere.properties
RUN mv /tmp/ksys/hazelcast.xml ${IDEMPIERE_HOME}/hazelcast.xml
RUN mv /tmp/ksys/jetty.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty.xml
RUN mv /tmp/ksys/jetty-alpn.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-alpn.xml
RUN mv /tmp/ksys/jetty-deployer.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-deployer.xml
RUN mv /tmp/ksys/jetty-http.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-http.xml
RUN mv /tmp/ksys/jetty-http2.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-http2.xml
RUN mv /tmp/ksys/jetty-https.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-https.xml
RUN mv /tmp/ksys/jetty-plus.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-plus.xml
RUN mv /tmp/ksys/jetty-selector.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-selector.xml
RUN mv /tmp/ksys/jetty-ssl.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-ssl.xml
RUN mv /tmp/ksys/jetty-ssl-context.xml ${IDEMPIERE_HOME}/jettyhome/etc/jetty-ssl-context.xml
RUN mv /tmp/ksys/webdefault.xml ${IDEMPIERE_HOME}/jettyhome/etc/webdefault.xml
RUN mv /tmp/ksys/ksys-demo-keystore ${IDEMPIERE_HOME}/jettyhome/etc/ksys-demo-keystore
RUN mv /tmp/ksys/ksys-idempiere-server.sh ${IDEMPIERE_HOME}/ksys-idempiere-server.sh


# Clean tmp/ksys
RUN rm -rf /tmp/ksys
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set +x for start script
RUN chmod 755 ${IDEMPIERE_HOME}/*.sh

EXPOSE 8080 8443 4554

# Add daemon to be run by runit.
RUN mkdir /etc/service/ksys-idempiere-server
RUN ln -s /opt/idempiere.gtk.linux.x86_64/idempiere-server/ksys-idempiere-server.sh /etc/service/ksys-idempiere-server/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
