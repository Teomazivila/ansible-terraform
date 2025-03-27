# Dockerfile for a lightweight DevOps tools container
FROM python:3.12-alpine

# Set timezone and environment variables (least likely to change)
ENV TZ=Europe/Minsk \
    PYTHONUNBUFFERED=1

# Install basic dependencies (changes less frequently)
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    jq \
    openssl \
    ca-certificates \
    tzdata \
    unzip \
    vim \
    sshpass \
    openssh-client \
    gnupg \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Install build dependencies for Python packages
RUN apk add --no-cache \
    python3-dev \
    gcc \
    g++ \
    make \
    libffi-dev \
    musl-dev

# Install Python packages (separate layer for Python packages)
RUN pip3 install --no-cache-dir \
    ansible \
    ansible-lint \
    boto3 \
    botocore \
    openshift \
    kubernetes \
    yamllint \
    pywinrm

# Install Ansible Galaxy collections
RUN mkdir -p /root/.ansible/collections \
    && ansible-galaxy collection install \
       ansible.posix \
       community.general \
       community.docker \
       community.aws

# Install Terraform
RUN wget -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_amd64.zip" \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm /tmp/terraform.zip \
    && chmod +x /usr/local/bin/terraform

# Install OpenTofu (alternative to Terraform)
RUN wget -O /tmp/opentofu.zip "https://github.com/opentofu/opentofu/releases/download/v1.6.2/tofu_1.6.2_linux_amd64.zip" \
    && unzip /tmp/opentofu.zip -d /usr/local/bin \
    && rm /tmp/opentofu.zip \
    && chmod +x /usr/local/bin/tofu

# Install Terragrunt
RUN wget -O /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.17/terragrunt_linux_amd64" \
    && chmod +x /usr/local/bin/terragrunt

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Packer
RUN wget -O /tmp/packer.zip "https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip" \
    && unzip /tmp/packer.zip -d /usr/local/bin \
    && rm /tmp/packer.zip \
    && chmod +x /usr/local/bin/packer

# Install minimal Azure CLI (using pip instead of the large package)
RUN pip install --no-cache-dir azure-cli

# Install minimal Google Cloud SDK CLI tools
RUN curl -sSL https://sdk.cloud.google.com > /tmp/gcl \
    && bash /tmp/gcl --install-dir=/usr/local --disable-prompts \
    && rm /tmp/gcl

# Add Docker CLI only
RUN wget -O /tmp/docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz \
    && tar xzvf /tmp/docker.tgz --strip 1 -C /usr/local/bin docker/docker \
    && rm /tmp/docker.tgz

# Create a non-root user for security
RUN addgroup -S devops && adduser -S devops -G devops
USER devops

# Set up a working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]