FROM openshift/origin-release:golang-1.13 AS builder
ADD . /source
RUN make -C /source build

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ADD html /var/www/html
COPY --from=builder /source/build/server /usr/local/bin/server

ENV PUBLIC_HTML=/var/www/html
EXPOSE 8080
ENTRYPOINT /usr/local/bin/server
