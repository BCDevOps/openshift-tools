FROM telegraf:alpine

MAINTAINER Shea Phillips <shea.phillips@cloudcompass.ca>

LABEL io.k8s.description="Platform for building telegraf images with specific metrics collectors, for incorporation into a TICK/TIG monitoring stack." \
      io.k8s.display-name="builder telegraf" \
      io.openshift.tags="builder,tick,telegraf,monitoring,metrics"


LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i

# remove the default configuration file
RUN rm /etc/telegraf/telegraf.conf && chmod a+w /etc/telegraf

# Set the default user for the image, the user itself was created in the base image
USER 1001

CMD ["usage"]
