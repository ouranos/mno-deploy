#!/bin/bash

#==============================================================
# This script runs ansible for each test environment and prepare
# live PaaS environments
#==============================================================

# Deploy the AWS Ubuntu Test environment
sh ci_environments/aws_ubuntu/scripts/setup_infrastructure.sh
