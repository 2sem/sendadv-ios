#!/bin/bash
#
# merge_skadnetworks.sh
#
# Post-build script that merges SKAdNetworkItems from skNetworks.plist into the built Info.plist.
# If Info.plist doesn't have SKAdNetworkItems yet, it adds the full list.
# If it already exists, it merges (adds missing identifiers) from skNetworks.plist.
#

set -euo pipefail

INFOPLIST_PATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
SKNETWORKS_PLIST="${SRCROOT}/Resources/skNetworks.plist"

if [ ! -f "${INFOPLIST_PATH}" ]; then
    echo "warning: Info.plist not found at ${INFOPLIST_PATH}"
    exit 0
fi

if [ ! -f "${SKNETWORKS_PLIST}" ]; then
    echo "warning: skNetworks.plist not found at ${SKNETWORKS_PLIST}"
    exit 0
fi

echo "Merging SKAdNetworkItems from skNetworks.plist into Info.plist..."

# Check if SKAdNetworkItems already exists in Info.plist
HAS_SKAD=$(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems" "${INFOPLIST_PATH}" 2>/dev/null && echo "yes" || echo "no")

if [ "${HAS_SKAD}" = "no" ]; then
    # No SKAdNetworkItems in Info.plist — copy the entire array from skNetworks.plist
    echo "SKAdNetworkItems not found in Info.plist. Adding all entries from skNetworks.plist..."

    COUNT=$(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems" "${SKNETWORKS_PLIST}" 2>/dev/null | grep -c "Dict {" || true)

    /usr/libexec/PlistBuddy -c "Add :SKAdNetworkItems array" "${INFOPLIST_PATH}"

    INDEX=0
    while true; do
        IDENTIFIER=$(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems:${INDEX}:SKAdNetworkIdentifier" "${SKNETWORKS_PLIST}" 2>/dev/null || echo "")
        if [ -z "${IDENTIFIER}" ]; then
            break
        fi
        /usr/libexec/PlistBuddy -c "Add :SKAdNetworkItems: dict" "${INFOPLIST_PATH}"
        LAST_INDEX=$(( $(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems" "${INFOPLIST_PATH}" | grep -c "Dict {" || true) - 1 ))
        /usr/libexec/PlistBuddy -c "Add :SKAdNetworkItems:${LAST_INDEX}:SKAdNetworkIdentifier string ${IDENTIFIER}" "${INFOPLIST_PATH}"
        INDEX=$(( INDEX + 1 ))
    done

    echo "Added ${INDEX} SKAdNetworkIdentifiers."
else
    # SKAdNetworkItems exists — merge missing entries
    echo "SKAdNetworkItems found in Info.plist. Merging missing entries from skNetworks.plist..."

    # Collect existing identifiers
    EXISTING=$(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems" "${INFOPLIST_PATH}" 2>/dev/null | grep "SKAdNetworkIdentifier = " | sed 's/.*SKAdNetworkIdentifier = //' | tr -d ';' | tr '[:upper:]' '[:lower:]')

    ADDED=0
    INDEX=0
    while true; do
        IDENTIFIER=$(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems:${INDEX}:SKAdNetworkIdentifier" "${SKNETWORKS_PLIST}" 2>/dev/null || echo "")
        if [ -z "${IDENTIFIER}" ]; then
            break
        fi

        LOWER_ID=$(echo "${IDENTIFIER}" | tr '[:upper:]' '[:lower:]')
        if ! echo "${EXISTING}" | grep -qF "${LOWER_ID}"; then
            /usr/libexec/PlistBuddy -c "Add :SKAdNetworkItems: dict" "${INFOPLIST_PATH}"
            LAST_INDEX=$(( $(/usr/libexec/PlistBuddy -c "Print :SKAdNetworkItems" "${INFOPLIST_PATH}" | grep -c "Dict {" || true) - 1 ))
            /usr/libexec/PlistBuddy -c "Add :SKAdNetworkItems:${LAST_INDEX}:SKAdNetworkIdentifier string ${IDENTIFIER}" "${INFOPLIST_PATH}"
            echo "  Added: ${IDENTIFIER}"
            ADDED=$(( ADDED + 1 ))
        fi

        INDEX=$(( INDEX + 1 ))
    done

    echo "Merge complete. Added ${ADDED} new SKAdNetworkIdentifiers."
fi

echo "Done."
