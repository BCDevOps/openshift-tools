FROM docker-registry.pathfinder.gov.bc.ca/openshift/jenkins-slave-python-rhel7

MAINTAINER Roland Stens <roland.stens@gmail.com>

USER root

# Labels consumed by Red Hat build service
#LABEL com.redhat.component="jenkins-slave-nodejs-rhel7-docker" \
#      name="openshift3/jenkins-slave-nodejs-rhel7" \
#      version="1.0" \
#      architecture="x86_64" \
#      release="6" \
#      io.k8s.display-name="Jenkins Slave Nodejs" \
#      io.k8s.description="The jenkins slave nodejs image has the nodejs tools on top of the jenkins slave base image." \
#      io.openshift.tags="openshift,jenkins,slave,nodejs"

ENV NODEJS_VERSION=6.9.1 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$PATH:$HOME/node_modules/.bin/:$HOME/.npm-global/bin/ \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable"

COPY contrib/bin/scl_enable /usr/local/bin/scl_enable

# Install NodeJS
    # yum-config-manager --enable rhel-server-rhscl-7-rpms && \    
    # yum-config-manager --enable rhel-7-server-optional-rpms && \
    # yum-config-manager --disable epel >/dev/null || : && \
RUN INSTALL_PKGS="rh-nodejs6 rh-nodejs6-nodejs-nodemon" && \
    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS
   # yum clean all -y

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

RUN source scl_source enable rh-python35 && \
    virtualenv /opt/app-root

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

USER 1001
