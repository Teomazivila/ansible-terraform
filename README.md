# Ansible-Terraform Docker Image

A lightweight Docker image that bundles infrastructure as code and DevOps tools in an Alpine Linux environment, providing a consistent and efficient platform for cloud automation workflows.

## Features

- Alpine Linux base image for minimal size (~600MB vs ~2GB for Ubuntu)
- Python 3.12 pre-installed with essential modules
- Ansible and Ansible Lint for configuration management
- Terraform and OpenTofu for infrastructure as code
- Cloud provider CLI tools (AWS, Azure, GCP)
- Kubernetes tools (kubectl, Helm)
- Docker CLI for container management
- Git and other essential development tools
- Security focused with non-root user by default
- Ready-to-use environment for DevOps tasks

## Performance Benefits

- **Smaller Image Size**: Up to 70% reduction compared to Ubuntu-based images
- **Faster CI/CD Builds**: Significantly reduced build and pull times
- **Lower Resource Usage**: Reduced memory footprint during runtime
- **Faster Layer Caching**: Smaller layers mean faster cache hits
- **Improved Security**: Alpine's minimal attack surface and non-root user

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

## Build Optimization

The Dockerfile is strategically structured to leverage Docker's layer caching mechanism, making builds faster and more efficient:

1. **Layer Ordering**: 
   - Least frequently changing components are placed first
   - Core dependencies are added in initial layers
   - Specific tools are grouped in logical layers based on change frequency

2. **Cache Efficiency**:
   - When adding new tools, only the affected layers need to be rebuilt
   - Base layers with common utilities remain cached
   - Similar tools are grouped together to minimize cache invalidation

3. **Alpine-specific Optimizations**:
   - Uses `apk add --no-cache` to avoid creating package caches
   - Downloads tools as compiled binaries where possible
   - Cleans up temporary files within each layer
   - Minimal runtime dependencies installed

This structure allows for easier maintenance and faster builds when updating or adding new tools.

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
- Azure CLI (minimal pip installation) - Microsoft Azure command-line interface
- Google Cloud SDK (minimal installation) - Google Cloud Platform command-line tools

### Container & Kubernetes
- Docker CLI - For container management
- kubectl - Kubernetes command-line tool
- Helm - Kubernetes package manager

### Utilities
- Python 3.12 & pip - With boto3, kubernetes, openshift, pywinrm
- Git - Version control
- jq - JSON processor
- vim - Text editor
- curl, wget - Network utilities
- unzip - Archive utility
- sshpass - Non-interactive ssh password provider
- bash - Shell

## Time Zone

The container is configured with Europe/Minsk time zone by default.

## CI/CD

This repository includes a GitHub Actions workflow that automatically builds and publishes the Docker image to DockerHub when:
- Changes are pushed to the main/master branch
- A new tag with prefix 'v' is created (e.g., v1.0.0)
- Manually triggered via GitHub Actions interface

### Build Performance Optimization

The CI/CD workflow is optimized to minimize build times through several caching strategies:

1. **Multi-level Caching**:
   - GitHub Actions cache for persistent layer storage between workflow runs
   - Registry-based caching to leverage previously pushed images
   - Local BuildKit cache for efficient layer reuse

2. **Cache Sources**:
   - Latest image from DockerHub used as cache source
   - Major version images used as fallback cache
   - Local cached layers from previous builds

3. **BuildKit Optimizations**:
   - Uses Docker BuildKit with inline caching enabled
   - Container-based BuildKit driver for better performance
   - Parallel building of multiple platforms

These optimizations ensure that when you add new tools or update existing ones, the build process reuses as many layers as possible from previous builds, significantly reducing build times and bandwidth usage.

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
