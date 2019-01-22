FROM registry.access.redhat.com/openshift3/ose-cli:v3.11.59

LABEL maintainer="Steven Barre <steven.barre@dxcas.com>"
LABEL io.k8s.description="Cron script runner with logging"

COPY cron-scripts /scripts
ENTRYPOINT ["/scripts/job-runner"]
