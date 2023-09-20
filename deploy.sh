#!/usr/bin/env bash

set -o nounset
set -o errexit

DOCKER=docker
PYTHON_IMAGE_TAG=python:3.8-bullseye
AWS_CLI_IMAGE_TAG=amazon/aws-cli

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname -- "$0")"
DIST_DIR="${SCRIPT_DIR%%/}/dist"
VENV_DIR="${SCRIPT_DIR%%/}/venv"
PACKAGE_NAME="$(basename "$(dirname "$(readlink -f -- "$0")")")"

function log_info() {
    # Call: log_info "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [INFO]: ${1}"
}
function log_error() {
    # Call: log_error "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [ERROR]: ${1}"
}

${DOCKER} run -it --rm --entrypoint /bin/bash \
    -v "$(pwd)":"/opt/${PACKAGE_NAME}" \
    ${PYTHON_IMAGE_TAG} -c "cd '/opt/${PACKAGE_NAME}' && /bin/bash package.sh"


${DOCKER} run -it --rm --entrypoint /bin/bash \
    -v "$(pwd)":"/opt/${PACKAGE_NAME}" \
    -v "${HOME}/.aws":/root/.aws \
    ${AWS_CLI_IMAGE_TAG} -c "cd '/opt/${PACKAGE_NAME}' && /bin/bash upload_to_s3.sh && /bin/bash update_in_dynamo.sh"
