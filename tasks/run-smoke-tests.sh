
#!/bin/bash

set -e
set -x

export CONFIG=$(pwd)/pipeline/tasks/integration_config.json

# Replace all variables with parameters from concourse
# Parameters are received as environment variables
vars=(API_URI APPS_DOMAIN CF_USER CF_PASSOWRD CF_ORG CF_SPACE)
for var in ${vars[@]}
do
  sed -i "s/\%${var}\%/${!var}/g" $CONFIG
done

echo "Using CONFIG=$CONFIG"

# Downloading CF CLI.
apk add --update curl
curl -L 'https://cli.run.pivotal.io/stable?release=linux64-binary' | tar -zx -C /usr/local/bin

# Run tests
pushd cf-smoke-tests
  ./bin/test -v
popd
