# WebMethods on AWS Elastic Container Service Example Set 01

A set of quick examples on how to use webMethods on AWS ECS.

## Prerequisites for this project

You must be able to run docker compose.

## Plan (Work in progress)

1. Find out a devcontainer solution zero for aws terraform.

    [Found](https://github.com/awslabs/aws-terraform-dev-container). Note that this should be a template, but it is not. Maybe I need to fork it and use it as a submodule here.
    Tested and the tools are ok. Not clear how to proceed for the terraform part itself.

    Update: The above solution is overengineered and doesn't seem to make sense from a devcontainers perspective. Looking elsewhere, e.g. at [tecracer proposal](https://www.tecracer.com/blog/2021/10/testing-terraform-with-inspec-part-2.html) which seems more controllable.

    Also, looking at multiple devcontainers for the current project, as it will definitely need more of them and we will also need to look at docker compose run-configurations to help with Software AG service development.

2. Find a way to provision ECS resources with VPCs using Terraform

    [Found](https://spacelift.io/blog/terraform-ecs)
    Does not contain the basic start commands, such as terraform init.

3. Find a way to prepare containers to use with ECS

    It seems it uses [CodePipeline](https://aws.amazon.com/codepipeline/).

4. Find a way to use CodePipeline to prepare the artifacts needed for the container images build.

    - Seems that CodePipeline's free tier is very shallow. Would it be better to use Azure DevOps instead?
    - [One not very helpful article](https://kapilbansal16.medium.com/comparison-between-azure-devops-and-aws-code-pipeline-2ecbace1167#:~:text=Azure%20DevOps%20offers%20a%20free,time%20spent%20running%20those%20pipelines.)
    - AWS free tier?[some tips](https://www.youtube.com/watch?v=pZLG8McSugQ)
      - Not useful in our case, but pay-per-use may result very convenient.
    - What is the equivalent of a Resource Group in AWS?
    - Research on AWS capabilities is somehow vast, maybe we can skip it?

## Log

### Creating devcontainer configuration for Terraform for AWS

#### 2023-12-27

- **13:22** - managed to spin up the first devcontainer. The trial from [tecracer proposal](https://www.tecracer.com/blog/2021/10/testing-terraform-with-inspec-part-2.html) did not work as expected. Fell back on a manual change of the original proposal.
