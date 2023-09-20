#!/usr/bin/env bash

set -o nounset
set -o errexit

PYTHON=python3.8

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

log_info "Creating virtualenv"
rm -rf "${VENV_DIR}"
${PYTHON} -m venv "${VENV_DIR}"
. "${VENV_DIR}"/bin/activate \

if [ -z "${VIRTUAL_ENV}" ]
then
    log_error "'${VENV_DIR}' is not valid python virtualenv"
    exit 1
fi

if [ -f "${SCRIPT_DIR}"/requirements.txt ]; then
    pip install --no-deps -r "${SCRIPT_DIR}"/requirements.txt
fi

log_info "Packaging '${PACKAGE_NAME}'"
rm -rf "${DIST_DIR}"
python setup.py sdist --dist-dir "${DIST_DIR}"
result=$?
if [ "${result}" != "0" ]; then
    log_error "Failed to package '${PACKAGE_NAME}'!"
fi
