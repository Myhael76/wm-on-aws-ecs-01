ARG VARIANT="ubuntu-22.04"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# Install OS packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        make \
    && mkdir -p /workspace \
    && chown vscode:vscode /workspace

USER vscode

# See https://github.com/terraform-docs/terraform-docs/releases
ARG TERRAFORM_DOCS_VERSION=0.17.0

# See https://github.com/aquasecurity/tfsec/releases
ARG TFSEC_VERSION=1.28.3

# See https://github.com/tenable/terrascan/releases
ARG TERRASCAN_VERSION=1.18.11

# See https://github.com/terraform-linters/tflint-ruleset-aws/releases
ARG TFLINT_AWS_RULESET_VERSION=0.28.0

RUN cd /tmp/ \
    && git clone -b main --depth 1 https://github.com/awslabs/aws-code-habits.git \
    && cd aws-code-habits \
    && make devcontainer/terraform/init \
    && rm -rf /tmp/aws-code-habits \
    && cd /workspace \
    && git config --global --add safe.directory /workspace

USER root
