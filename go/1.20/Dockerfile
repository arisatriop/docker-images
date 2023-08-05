FROM ubuntu:20.04

LABEL MAINTAINER="Ari Satrio<arisatrioputra03@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# Update and upgrade repo
RUN apt-get update -y -q && apt-get upgrade -y -q 

# Install tools we might need
RUN apt-get install --no-install-recommends -y -q \ 
    curl \
    build-essential \
    ca-certificates git \
    libmagickwand-dev

# Download Go 1.7.3 and install it to /usr/local/go
RUN curl -s https://dl.google.com/go/go1.20.7.linux-amd64.tar.gz | tar -v -C /usr/local -xz

# Let's people find my Go binaries
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
