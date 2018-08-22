FROM golang:1.10

RUN \
    go get -d github.com/Azure/azure-event-hubs-go && \
    go get -d github.com/stretchr/testify/assert && \
    go get -d github.com/giventocode/openshift-tools/monitoring/az-provisioning-event-collector/azcollect && \
    go get -d github.com/giventocode/openshift-tools/monitoring/az-provisioning-event-collector/azcollect && \
    cd $GOPATH/src/github.com/giventocode/openshift-tools/monitoring/az-provisioning-event-collector/azcollect && \
    go test -v ./... && \
    go install github.com/giventocode/openshift-tools/monitoring/az-provisioning-event-collector/azcollect
