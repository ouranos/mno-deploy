#!/bin/bash
APP_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )

# Move to test directory
cd $APP_ROOT/tests

#--------------------------------------------------------
# 1. Check syntax of ansible scripts
#--------------------------------------------------------
echo "Checking Ansible syntax..."
./1-check-syntax.sh

if [ $? -eq 0 ]; then
  echo "Ansible syntax is correct"
else
  echo "Ansible syntax incorrect"
  exit 1
fi

# Stop here if end-to-end testing is not enabled
if [ "$TST_ENABLED" != "true" ];  then
  echo "Skipping end-to-end tests"
  exit 0
fi

#--------------------------------------------------------
# 2. Publish Core deployment scripts to a CI bucket
#--------------------------------------------------------
echo "Publishing core deployment scripts onto staging..."
./2-publish-ci-pkg.sh

if [ $? -eq 0 ]; then
  echo "Core deployment scripts have been published to CI bucket"
else
  echo "Unable to publish core deployment scripts to CI bucket"
  exit 1
fi

#--------------------------------------------------------
# 3. Publish test environment configuration to a CI bucket
#--------------------------------------------------------
echo "Publishing core deployment scripts onto staging..."
./3-publish-ci-config.sh

if [ $? -eq 0 ]; then
  echo "Configuration scripts have been published to CI bucket"
else
  echo "Unable to publish configuration scripts to CI bucket"
  exit 1
fi

#--------------------------------------------------------
# 4. Setup test environments
#--------------------------------------------------------
echo "Setting up test environments..."
./4-setup-ci-infra.sh

if [ $? -eq 0 ]; then
  echo "Test environment(s) have been successfully setup"
else
  echo "Unable to properly setup test environment(s)"
  exit 1
fi

# Go back to top directory
cd $APP_ROOT
