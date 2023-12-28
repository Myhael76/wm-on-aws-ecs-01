#!/bin/sh

runCmd(){
  echo "============== Executing command $1"
  $1
  echo "============== Command $1 exitted with code $?"
}

runCmd "aws ec2 describe-vpcs"
runCmd "aws ec2 describe-subnets"
runCmd "aws ec2 describe-security-groups"
runCmd "aws resource-groups list-groups"
runCmd "aws resource-groups list-group-resources --group rg4pj-aws-tf-01"
