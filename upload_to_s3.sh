#!/usr/bin/env bash

set -o nounset
set -o errexit

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname -- "$0")"
DIST_DIR="${SCRIPT_DIR%%/}/dist"
VENV_DIR="${SCRIPT_DIR%%/}/venv"
PACKAGE_NAME="$(basename "$(dirname "$(readlink -f -- "$0")")")"

PLUGINS_S3_BASE_CIRRUS="s3://plugins-syd-cirrus/cortex_plugins"
PLUGINS_S3_BASE_CLOUD="s3://plugins-syd-cloud/cortex_plugins"

function log_info() {
    # Call: log_info "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [INFO]: ${1}"
}
function log_error() {
    # Call: log_error "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [ERROR]: ${1}"
}

function upload_to_s3() {
    # Call: upload_to_s3 "<package_local_path>" "<package_s3_path>" "<aws_profile_name>"
    package_local_path="$1"
    package_s3_path="$2"
    aws_profile_name="$3"

    log_info "Uploading '${package_local_path}' to '${package_s3_path}' for '${aws_profile_name}'"
    aws --profile "${aws_profile_name}" --region ap-southeast-2 s3 cp "${package_local_path}" "${package_s3_path}"

    result=$?
    if [ "${result}" != "0" ]; then
        log_error "Failed to upload '${package_local_path}' to '${package_s3_path}' for '${aws_profile_name}'"
        exit 1
    fi
    log_info "Successfully uploaded '${package_local_path}' to '${package_s3_path}' for '${aws_profile_name}'"
}

package_file_path="$(ls "${DIST_DIR}"/"${PACKAGE_NAME}"*.tar.gz)"
package_file_name=$(basename "${package_file_path}")

package_s3_path_cirrus="${PLUGINS_S3_BASE_CIRRUS}/${PACKAGE_NAME}/${package_file_name}"
upload_to_s3 "${package_file_path}" "${package_s3_path_cirrus}" "unleash-dev"

package_s3_path_cloud="${PLUGINS_S3_BASE_CLOUD}/${PACKAGE_NAME}/${package_file_name}"
upload_to_s3 "${package_file_path}" "${package_s3_path_cloud}" "unleash-prod"
