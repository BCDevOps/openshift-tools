FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7

EXPOSE 8080

ENV PATH=$HOME/.local/bin/:$PATH \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PYTHON_VERSION=3.6 \
    PATH=$HOME/.local/bin/:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    PIP_NO_CACHE_DIR=off
   
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
    yum clean all -y && \
    yum update -y
    
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update    
    
RUN PYTHON_INSTALL_PKGS="rh-python36 rh-python36-python-devel rh-python36-python-setuptools rh-python36-python-pip" && \
    yum install -y --setopt=tsflags=nodocs $PYTHON_INSTALL_PKGS

RUN X11_INSTALL_PKGS="xorg-x11-server-Xorg xorg-x11-drv-intel xorg-x11-server-Xvfb xorg-x11-xinit xorg-x11-xdm terminus-fonts xterm" &&\
    yum install -y --setopt=tsflags=nodocs $X11_INSTALL_PKGS

# RUN EXTRA_INSTALL_PKGS="xmlstarlet x11vnc openbox"

RUN yum groupinstall -y 'X Window System'

RUN INSTALL_PKGS="make automake autoconf gcc gcc-c++ libstdc++ libstdc++-devel net-tools curl wget firefox nss_wrapper" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS

#RUN xml
#RUN pip -h

#RUN pip install --upgrade pip
#RUN pip install zapcli
#RUN pip install python-owasp-zap-v2.4

RUN mkdir -p /zap/wrk

ADD zap /zap/
ENV PATH /zap:$PATH
ENV ZAP_PATH /zap/zap.sh
ENV ZAP_PORT 8080
COPY policies /var/lib/jenkins/.ZAP/policies/
COPY .xinitrc /var/lib/jenkins/
WORKDIR /zap

# Download and expand the latest stable release 
# RUN curl -s https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions-dev.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget -q --content-disposition -i - -O - | tar zx --strip-components=1 && \
#    curl -s -L https://bitbucket.org/meszarv/webswing/downloads/webswing-2.3-distribution.zip | jar -x && \
#    touch AcceptedLicense

ADD webswing.config /zap/webswing-2.3/webswing.config

RUN chown root:root /zap -R && \
    chmod 777 /zap -R

ENV OPENSHIFT_JENKINS_JVM_ARCH=x86_64

#USER 1001
