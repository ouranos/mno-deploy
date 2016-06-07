#!/bin/bash

#==============================================================
# This script runs ansible for each test environment and prepare
# live PaaS environments
#==============================================================

# Deploy the AWS Ubuntu Test environment
sh ci_environments/aws_ubuntu/scripts/setup_infrastructure.sh
retval=$?

if [ $retval -eq 0 ]; then
  # Give some time to the infrastructure to prepare
  echo "[RUN] sleep for 5 minutes while infrastructure is provisioning"
  sleep 300
fi

exit $retval
