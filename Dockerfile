# Dockerfile for setting up an Ubuntu container with DevOps tools
FROM ubuntu:24.04

# Set timezone and non-interactive mode (least likely to change)
ENV TZ=Europe/Minsk \
    DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add all repository sources first (changes less frequently)
RUN apt-get -qy update && apt-get install -qy \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    wget \
    lsb-release \
    && apt-add-repository --yes --update ppa:ansible/ansible \
    # HashiCorp repository
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    # Google Cloud repository
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    # Docker repository
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get -qy update

# Install core tools and utilities (common dependencies most likely to be reused)
RUN apt-get install -qy \
    git \
    unzip \
    jq \
    vim \
    less \
    python3 \
    python3-pip \
    sshpass \
    net-tools \
    iputils-ping \
    dnsutils \
    && apt-get clean

# Install infrastructure tools from apt (most likely to change, but install via apt)
RUN apt-get install -qy \
    ansible \
    ansible-lint \
    terraform \
    packer \
    docker-ce-cli \
    google-cloud-cli \
    && apt-get clean

# Install Azure CLI (separate layer for cloud tools)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && apt-get clean

# Install AWS CLI (separate layer because it's downloaded as a binary)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Kubernetes tools (separate layer for k8s)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/ \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Ansible Galaxy collections (separate layer for collections)
RUN ansible-galaxy collection install \
    ansible.posix \
    community.general \
    community.docker \
    community.aws


# Install alternative IaC tools (separate layer for binary tools) 
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method standalone \
    && rm install-opentofu.sh \
    && curl -Lo /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.17/terragrunt_linux_amd64" \
    && chmod +x /usr/local/bin/terragrunt

# Final cleanup (always run at the end)
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up a working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]