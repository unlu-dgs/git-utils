FROM ubuntu:latest
MAINTAINER tdelvechio@unlu.edu.ar

RUN export http_proxy=http://proxy.unlu.edu.ar:8080 \
 && export https_proxy=http://proxy.unlu.edu.ar:8080 \
 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git-crypt \
 && rm -rf /var/lib/apt/lists/*

