#!/bin/sh

set -e

set -o pipefail

echo "Interpolating config..."
export CONFIG=$(pwd)/pipeline/tasks/smoke_config.json

export JOB_PWD=$(pwd)

# Replace all variables with parameters from concourse
# Parameters are received as environment variables
sed -i 's,\%API_URI\%,'"${API_URI}"',g' $CONFIG
sed -i 's,\%APPS_DOMAIN\%,'"${APPS_DOMAIN}"',g' $CONFIG
sed -i 's,\%CF_USER\%,'"${CF_USER}"',g' $CONFIG
sed -i 's,\%CF_PASSOWRD\%,'"${CF_PASSOWRD}"',g' $CONFIG
sed -i 's,\%CF_ORG\%,'"${CF_ORG}"',g' $CONFIG
sed -i 's,\%CF_SPACE\%,'"${CF_SPACE}"',g' $CONFIG

echo "Installing packages..."
apk add --update curl bash git
curl -L 'https://cli.run.pivotal.io/stable?release=linux64-binary' | tar -zx -C /usr/local/bin

# Link to gopath
mkdir -p /go/src/github.com/cloudfoundry
ln -s `pwd`/cf-smoke-tests /go/src/github.com/cloudfoundry/cf-smoke-tests

# Run tests
echo "Starting tests..."
cd /go/src/github.com/cloudfoundry/cf-smoke-tests && ./bin/test -v | tee $JOB_PWD/run-stats/build-output.txt

tail -n 3 $JOB_PWD/run-stats/build-output.txt | grep "Ginkgo ran" | rev | cut -d' ' -f 1 | rev > $JOB_PWD/run-stats/build-time-$(date +%s).txt

cp $JOB_PWD/run-stats/build-time-$(date +%s).txt $JOB_PWD/run-stats/build-time.txt
