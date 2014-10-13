#!/bin/bash
#
# Read an instance's AWS role credentials from Amazon's API.
#
# Source this from any shell scripts on the box that need access to the
# instance's role credentials
#
# If it matters, this is MIT licensed.

read_iam_role_credentials_or_die(){
  local IAM_ENDPOINT="http://169.254.169.254/latest/meta-data/iam"

  local security_profile=$(curl -s ${IAM_ENDPOINT}/security-credentials/)

  local count=$(echo ${security_profile} | grep -c '<h1>404 - Not Found</h1>')

  if [ "$(echo ${security_profile} | grep -c '<h1>404 - Not Found</h1>')" -gt 0 ]; then
    echo "This machine does not have an IAM role"
    exit 1
  fi

  export AWS_ACCESS_KEY_ID=$(curl -s ${IAM_ENDPOINT}/security-credentials/${security_profile} | \
                               grep AccessKeyId | \
                               cut -d':' -f2 | \
                               sed 's/[^0-9A-Z]*//g')

  export AWS_SECRET_ACCESS_KEY=$(curl -s ${IAM_ENDPOINT}/security-credentials/${security_profile} | \
                                   grep SecretAccessKey | \
                                   cut -d':' -f2 | \
                                   sed 's/[^0-9A-Za-z/+=]*//g')
}
