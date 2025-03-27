# Dockerfile for setting up an Ubuntu container that has Ansible in it
FROM ubuntu:24.04

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt-get -qy update

RUN apt install -qy python software-properties-common git curl
RUN apt-add-repository --yes --update ppa:ansible/ansible
RUN apt install -qy ansible ansible-lint

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt update && apt install -yq terraform

CMD ["/bin/bash"]