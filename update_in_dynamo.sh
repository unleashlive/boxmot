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

PLUGINS_DYNAMODB_TABLE_NAME="plugin"
PLUGINS_DYNAMODB_ID_PROP_NAME="id"
PLUGINS_DYNAMODB_PACKAGE_NAME_PROP_NAME="packageName"
PLUGINS_DYNAMODB_S3_PATH_PROP_NAME="packageS3Path"

function log_info() {
    # Call: log_info "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [INFO]: ${1}"
}
function log_error() {
    # Call: log_error "message"
    >&2 echo "[$(date -u +'%Y-%m-%d %H:%M:%S %Z')] [${SCRIPT_NAME}] [ERROR]: ${1}"
}

function update_in_dynamo() {
    # Call: update_in_dynamo "<package_s3_path>" "<aws_profile_name>"
    package_s3_path="$1"
    aws_profile_name="$2"

    log_info "Updating '${PACKAGE_NAME}' within '${PLUGINS_DYNAMODB_TABLE_NAME}' for '${aws_profile_name}'"
    update_result="$(
        aws --region "ap-southeast-2" --profile="${aws_profile_name}" dynamodb put-item \
            --table-name="${PLUGINS_DYNAMODB_TABLE_NAME}" \
            --item='{"'"${PLUGINS_DYNAMODB_ID_PROP_NAME}"'": {"S": "'"${PACKAGE_NAME}"'"}, "'"${PLUGINS_DYNAMODB_PACKAGE_NAME_PROP_NAME}"'": {"S": "'"${PACKAGE_NAME}"'"}, "'"${PLUGINS_DYNAMODB_S3_PATH_PROP_NAME}"'": {"S": "'"${package_s3_path}"'"}}'
    )"

    result=$?
    if [ "${result}" != "0" ]; then
        log_error "Failed to update '${PACKAGE_NAME}' in '${PLUGINS_DYNAMODB_TABLE_NAME}' dynamodb table for '${aws_profile_name}'"
        exit 1
    fi
    log_info "Successfully updated '${PACKAGE_NAME}' in '${PLUGINS_DYNAMODB_TABLE_NAME}' dynamodb table for '${aws_profile_name}'"
}

package_file_path="$(ls "${DIST_DIR}"/"${PACKAGE_NAME}"*.tar.gz)"
package_file_name=$(basename "${package_file_path}")

package_s3_path_cirrus="${PLUGINS_S3_BASE_CIRRUS}/${PACKAGE_NAME}/${package_file_name}"
update_in_dynamo "${package_s3_path_cirrus}" "unleash-dev"


package_s3_path_cloud="${PLUGINS_S3_BASE_CLOUD}/${PACKAGE_NAME}/${package_file_name}"
update_in_dynamo "${package_s3_path_cloud}" "unleash-prod"
