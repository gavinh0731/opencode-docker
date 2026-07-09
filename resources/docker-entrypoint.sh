#!/usr/bin/env bash

set -e

LOCAL_UID_VALUE="${LOCAL_UID:-1000}"
LOCAL_GID_VALUE="${LOCAL_GID:-1000}"
LOCAL_USER_NAME="${LOCAL_USER:-developer}"

echo "Creating user:"
echo "  USER=${LOCAL_USER_NAME}"
echo "  UID=${LOCAL_UID_VALUE}"
echo "  GID=${LOCAL_GID_VALUE}"

#
# 建立 group
#
if ! getent group "${LOCAL_GID_VALUE}" >/dev/null; then
    groupadd \
        -g "${LOCAL_GID_VALUE}" \
        "${LOCAL_USER_NAME}"
fi

#
# 建立 user
#
if ! id "${LOCAL_USER_NAME}" >/dev/null 2>&1; then
    useradd \
        -u "${LOCAL_UID_VALUE}" \
        -g "${LOCAL_GID_VALUE}" \
        -m \
        -s /bin/bash \
        "${LOCAL_USER_NAME}"
fi

HOME_DIR="/home/${LOCAL_USER_NAME}"

mkdir -p \
    "${HOME_DIR}/.local" \
    "${HOME_DIR}/.config"

chown \
    -R "${LOCAL_UID_VALUE}:${LOCAL_GID_VALUE}" \
    "${HOME_DIR}"

export HOME="${HOME_DIR}"

cd /workspace

echo "Running as:"
id

exec su - "${LOCAL_USER_NAME}" -c "cd /workspace && $*"