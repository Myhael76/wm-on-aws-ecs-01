#!/bin/sh

# run from parent folder with ./util/planWithTfvars.sh

terraform plan --var-file=test.tfvars
