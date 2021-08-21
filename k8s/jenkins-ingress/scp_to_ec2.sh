#!/bin/bash

set -euxo pipefail

scp -i ~/.ssh/aws-fly-devops.pem -r ./* ec2-user@ec2-3-144-118-29.us-east-2.compute.amazonaws.com:/home/ec2-user/k8s/
