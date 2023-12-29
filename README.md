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
- **16:00** - Trying to understand the options and to decide on how to store AWS connection credentials
  - the simplest way is to set the environment variables according to the [official docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build). This seems to be enough for the current purpose, more articulated solutions are likely to be necessary for production environments
- **18:00** - Playing around with VPCs and subnets. Checkov works, it recommends the VPC to have a security group that denies all traffic
- **20:50** - Finished debugging the checkov extension. I was misled by the "Prisma" notes and tried the token syntax for that one, but in reality I only needed to add the naked token and leave the Prisma API url empty.
- Now I need to understand how to manage the terraform state


#### 2023-12-28

- Struggled with Terraform errors that were not clear. There is some cognitive ramp up in the domain
- Resource explorer does not show VPCs (??). They are visible from the root exploration for services, look for VPC
- Now adding tags. It seems it is important to work with tags in AWS, otherwise it is difficult to find resources.
  - Also learning how to concatenate strings...
  - Also learning how to inspect what we did from aws cli
- Gradually extending
  - tags
  - resource group based on tag


#### 2023-12-29

- Reviewed the structure of .devcontainer folder, making a union with the docker compose contents. Studied the structure of the dev-containers solution and found a number of inconsistencies and improvement points. To reserve eventual improvements for the future, the solution is good enough for now.
- Tested the project with a second clone, with the intention of generating two sets of variables. It fails for name conflicts, thus decided to add a prefix to names.
- Refactor to modules to keep concerns separated and learn modules
- trunk linter manager seems to behave differently from the linters themselves. e.g. checkov did not protest at a 5 days logs retention, but trunk with checkov did. (?). However trunk seems more aggressive and for one that would follow stricter discipline may do well.
- It seems there is an issue with FlowLogs, they are not getting destroyed
- Added ECS capacity provider and a hello-world task definition.
- Added a service according to definition. It should fail because it can't pull the image. I'd like to see the output in the CloudWatch logs
  - Got it, it required a bit of navigation