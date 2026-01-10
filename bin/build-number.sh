#!/bin/bash

set -o pipefail

PROJECT_DIRECTORY=EssentialAppCaseStudy

# Enter project directory and set build number, then return to previous directory
pushd ${PROJECT_DIRECTORY}

BUILD_NUMBER=$(date -u +%Y.%m%d).$GITHUB_RUN_NUMBER
agvtool new-version -all "${BUILD_NUMBER}"
echo "Build number: (${BUILD_NUMBER})"

popd