FROM openshift/jenkins-slave-python-rhel7:latest

# Labels consumed by Red Hat build service
LABEL name="openshift/jenkins-slave-pythonnodejs-rhel7" \
      version="3.6" \
      architecture="x86_64" \
      release="4" \
      io.k8s.display-name="Jenkins Slave PythonNodejs" \
      io.k8s.description="The jenkins slave Python/nodejs image has the nodejs tools on top of the jenkins Python slave base image." \
      io.openshift.tags="openshift,jenkins,slave,nodejs,python"

ENV NODEJS_VERSION=4.4 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable"

COPY contrib/bin/scl_enable /usr/local/bin/scl_enable

# Install NodeJS
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \    
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --disable epel >/dev/null || : && \
    INSTALL_PKGS="rh-nodejs4 rh-nodejs4-nodejs-nodemon" && \
    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001
