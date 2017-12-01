FROM registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7
 
EXPOSE 8080
 
ENV PATH=$HOME/.local/bin/:$PATH \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
 
ENV SUMMARY="Jenkins slave with chrome installed." \
    DESCRIPTION="Jenkins pipeline slave with chrome."
 
LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Jenkins-Pipeline-Chrome" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,chrome,jenkins-jnlp" \
      release="1"
 
# We need to call 2 (!) yum commands before being able to enable repositories properly
# This is a workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1479388
# Chrome install info: https://access.redhat.com/discussions/917293
RUN yum repolist > /dev/null && \
    yum install -y yum-utils && \
    yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-fastrack-rpms && \
    INSTALL_PKGS="redhat-lsb libXScrnSaver wget firefox" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    #rpm -e --nodeps redhat-logos && \
    yum clean all -y && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
    yum -y localinstall google-chrome-stable_current_x86_64.rpm && \
    rm google-chrome-stable_current_x86_64.rpm
 
# Add Chrome as a user
# RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
#    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome
 
USER 1001
