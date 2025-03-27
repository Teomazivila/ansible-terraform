# Ansible-Terraform Docker Image

A comprehensive Docker image that bundles infrastructure as code and DevOps tools in an Ubuntu 24.04 environment, providing a consistent platform for cloud automation workflows.

## Features

- Ubuntu 24.04 base image
- Ansible and Ansible Lint for configuration management
- Terraform and OpenTofu for infrastructure as code
- Cloud provider CLI tools (AWS, Azure, GCP)
- Kubernetes tools (kubectl, Helm)
- Docker CLI for container management
- Git and other essential development tools
- Ready-to-use environment for DevOps tasks

## Usage

### Building the Image

```bash
docker build -t ansible-terraform .
```

### Running the Container

```bash
docker run -it ansible-terraform
```

### Using with Your Infrastructure Code

Mount your project directory to work with your infrastructure code:

```bash
docker run -it -v $(pwd):/workspace -w /workspace ansible-terraform
```

### Using the Pre-built Image from DockerHub

```bash
# Latest stable version
docker pull <your-dockerhub-username>/ansible-terraform:latest

# Specific version
docker pull <your-dockerhub-username>/ansible-terraform:1.0.0

# Major version only (always pulls the latest 1.x.x)
docker pull <your-dockerhub-username>/ansible-terraform:1

# Major.Minor version (always pulls the latest 1.2.x)
docker pull <your-dockerhub-username>/ansible-terraform:1.2

docker run -it -v $(pwd):/workspace -w /workspace <your-dockerhub-username>/ansible-terraform:tag
```

## Included Tools

### Infrastructure as Code
- Terraform - HashiCorp's infrastructure as code tool
- OpenTofu - Community-driven Terraform alternative
- Terragrunt - Terraform wrapper for DRY configurations
- Packer - HashiCorp's machine image builder
- Ansible & Ansible Lint - Configuration management and deployment
- Ansible Galaxy collections - General, Posix, Docker, AWS

### Cloud Provider Tools
- AWS CLI - Amazon Web Services command-line interface
- Azure CLI - Microsoft Azure command-line interface
- Google Cloud SDK - Google Cloud Platform command-line tools

### Container & Kubernetes
- Docker CLI - For container management
- kubectl - Kubernetes command-line tool
- Helm - Kubernetes package manager

### Utilities
- Python 3 & pip - With boto3, kubernetes, openshift, pywinrm
- Git - Version control
- jq - JSON processor
- vim - Text editor
- curl, wget - Network utilities
- unzip - Archive utility
- sshpass - Non-interactive ssh password provider
- net-tools, iputils-ping, dnsutils - Network diagnostic tools

## Time Zone

The container is configured with Europe/Minsk time zone by default.

## CI/CD

This repository includes a GitHub Actions workflow that automatically builds and publishes the Docker image to DockerHub when:
- Changes are pushed to the main/master branch
- A new tag with prefix 'v' is created (e.g., v1.0.0)
- Manually triggered via GitHub Actions interface

### Automatic Versioning

The CI/CD pipeline automatically handles versioning for you:

1. When you push to the main/master branch, a new version tag is automatically created and pushed:
   - By default, the patch version is incremented (e.g., 1.0.0 → 1.0.1)
   - Include `#minor` in your commit message to bump the minor version (e.g., 1.0.0 → 1.1.0)
   - Include `#major` in your commit message to bump the major version (e.g., 1.0.0 → 2.0.0)

2. The Docker image is then built and tagged with:
   - Full version tag (e.g., 1.2.3)
   - Major.Minor tag (e.g., 1.2)
   - Major version tag (e.g., 1)
   - Latest tag

You don't need to manually create tags - the workflow handles this automatically!

### Versioning Strategy

The image follows semantic versioning principles with the following tag formats:

- `latest` - Always points to the most recent stable build from the default branch
- `X.Y.Z` - Specific version (e.g., `1.2.3`)
- `X.Y` - Latest patch version of a specific minor version (e.g., `1.2`)
- `X` - Latest minor.patch version of a specific major version (e.g., `1`)
- `commit-abc123` - Specific commit hash for precise tracking

### Setup for GitHub Actions

To enable the automated builds, add the following secrets to your GitHub repository:
- `DOCKERHUB_USERNAME`: Your DockerHub username
- `DOCKERHUB_TOKEN`: Your DockerHub access token (not your password)

## License

See the [LICENSE](LICENSE) file for details.
