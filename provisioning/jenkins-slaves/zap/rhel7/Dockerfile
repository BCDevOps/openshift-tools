FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7

EXPOSE 8080

ENV PATH=$HOME/.local/bin/:$PATH \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
   
ENV SUMMARY="OWASP ZAP Jenkins slave." \
    DESCRIPTION="Jenkins pipeline slave with OWASP ZAP."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Jenkins-Pipeline-OWASP-ZAP" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,jenkins-jnlp-owasp-zap,jenkins-jnlp" \
      release="1"
      
# NOTES:
# We need to call 2 (!) yum commands before being able to enable repositories properly
# This is a workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1479388
# Chrome install info: https://access.redhat.com/discussions/917293
RUN yum repolist > /dev/null && \
    yum install -y yum-utils && \
    yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-extras-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-fastrack-rpms && \
    yum-config-manager --enable epel && \
    yum clean all -y
    # yum update -y

RUN yum install -y redhat-rpm-config \
    make automake autoconf gcc gcc-c++ libstdc++ libstdc++-devel \
    java-1.8.0-openjdk java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel \
    wget nano curl git gzip gettext tar xorg-x11-server-Xvfb xterm vnc-server \
    net-tools python27-python-pip firefox nss_wrapper  && \
    yum -y clean all

RUN wget https://pypi.python.org/packages/source/s/setuptools/setuptools-7.0.tar.gz --no-check-certificate && \
    tar xzf setuptools-7.0.tar.gz && \
    cd setuptools-7.0 && \
    python setup.py install
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py

RUN pip install --upgrade pip && \
    pip install zapcli && \
    pip install python-owasp-zap-v2.4

COPY rpms/*.rpm ./

RUN yum -y localinstall xmlstarlet-1.6.1-1.el7.x86_64.rpm && \
    yum -y localinstall imlib2-1.4.5-9.el7.x86_64.rpm && \
    yum -y localinstall pyxdg-0.25-2.el7.nux.noarch.rpm && \
    yum -y localinstall openbox-libs-3.5.2-6.2.x86_64.rpm && \
    yum -y localinstall openbox-3.5.2-6.2.x86_64.rpm && \
    yum -y localinstall x11vnc-0.9.13-11.el7.x86_64.rpm && \
    yum -y clean all && \
    rm ./*.rpm && \
    mkdir -p /zap/wrk && \
    mkdir -p /var/lib/jenkins/.vnc

ADD zap /zap/

RUN mkdir /zap@tmp && \
    chmod -v -R 777 /zap@tmp

# Copy the entrypoint
COPY configuration/* /var/lib/jenkins/

ENV PATH /zap:$PATH
ENV ZAP_PATH /zap/zap.sh
ENV HOME /var/lib/jenkins

# Default port for use with zapcli
ENV ZAP_PORT 8080

COPY policies /var/lib/jenkins/.ZAP/policies/
COPY .xinitrc /var/lib/jenkins/

WORKDIR /zap
# Download and expand the latest stable release 
RUN curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions-dev.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget -q --content-disposition -i - -O - | tar zx --strip-components=1 && \
    curl -s -L https://bitbucket.org/meszarv/webswing/downloads/webswing-2.3-distribution.zip | jar -x && \
    touch AcceptedLicense
RUN curl -s https://github.com/zaproxy/zaproxy/releases/download/2.7.0/ZAP_2.7.0_Linux.tar.gz

ADD webswing.config /zap/webswing-2.3/webswing.config

RUN chown -v -R root:root /zap && \
    chown -v -R root:root /var/lib/jenkins && \
    chmod -v -R 777 /var/lib/jenkins && \
    chmod -v -R 777 /zap

WORKDIR /var/lib/jenkins

ENV OPENSHIFT_JENKINS_JVM_ARCH=x86_64

USER 1001
