# Dockerfile for setting up an Ubuntu container with DevOps tools
FROM ubuntu:24.04

# Set timezone and non-interactive mode
ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt-get -qy update

# Install common dependencies
RUN apt-get install -qy \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    curl \
    wget \
    unzip \
    jq \
    vim \
    less \
    python3 \
    python3-pip \
    sshpass \
    net-tools \
    iputils-ping \
    dnsutils

# Install Ansible
RUN apt-add-repository --yes --update ppa:ansible/ansible
RUN apt-get install -qy ansible ansible-lint

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && apt-get install -qy terraform

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Packer
RUN apt-get install -y packer

# Install Ansible Galaxy collections
RUN ansible-galaxy collection install ansible.posix community.general community.docker community.aws


# Install OpenTofu (alternative to Terraform)
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method standalone \
    && rm install-opentofu.sh

# Install Terragrunt
RUN curl -Lo /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.17/terragrunt_linux_amd64" \
    && chmod +x /usr/local/bin/terragrunt

# Clean up APT cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up a working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]