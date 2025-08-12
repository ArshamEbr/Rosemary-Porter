#!/usr/bin/env bash

ROOT_DIR="$(dirname "$(readlink -f "$0")")"

BINARY_DIR="${ROOT_DIR}/binary"

BUSYBOX_DIR="${BINARY_DIR}/busybox"

# install busybox for the first time
if [[ $(find "${BUSYBOX_DIR}" | wc -l) -eq 2 ]]; then
    "${BUSYBOX_DIR}/busybox" --install -s "${BUSYBOX_DIR}"

    # remove conflicting applets
    for file in fuser mke2fs tune2fs xxd; do
        rm -f "${BUSYBOX_DIR}/${file}"
    done
fi

"${BINARY_DIR}/m_menu"
