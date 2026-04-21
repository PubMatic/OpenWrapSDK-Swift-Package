#!/bin/bash

# PubMatic Inc. ("PubMatic") CONFIDENTIAL
# Unpublished Copyright (c) 2006-2026 PubMatic, All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and
# technical concepts contained herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents,
# patents in process, and are protected by trade secret or copyright law. Dissemination of this information or
# reproduction of this material is strictly forbidden unless prior written permission is obtained from PubMatic.
# Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees,
# managers or contractors who have executed Confidentiality and Non-disclosure agreements explicitly covering
# such access or to such other persons whom are directly authorized by PubMatic to access the source code and
# are subject to confidentiality and nondisclosure obligations with respect to the source code.
#
# The copyright notice above does not evidence any actual or intended publication or disclosure of this source code,
# which includes information that is confidential and/or proprietary, and is a trade secret, of PubMatic.
# ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC PERFORMANCE, OR PUBLIC DISPLAY OF OR THROUGH USE OF THIS
# SOURCE CODE WITHOUT THE EXPRESS WRITTEN CONSENT OF PUBMATIC IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
# LAWS AND INTERNATIONAL TREATIES. THE RECEIPT OR POSSESSION OF THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT
# CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL
# ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.


# ---------------------------------------------------------------------------------------
# POBAddQuerySchemesScript.sh - Script to add URL schemes to App's Info.plist
# ---------------------------------------------------------------------------------------
#
# This script fetches required URL schemes from an API endpoint and adds them to the
# LSApplicationQueriesSchemes key in the app's Info.plist file during the build phase.
# If the API yields no usable schemes (network failure, status code not in 2xx range, empty body, invalid JSON,
# or missing/empty appInstallStatus.iOS data), the script logs the reason, exits 0, and does not
# read or modify Info.plist.
# The script always exits 0 so it never fails the Xcode build; errors are logged only.
# The script only executes for Release build configuration.
# Uses curl, plutil, PlistBuddy, and common shell utilities (same stack as Xcode builds on macOS).
# ---------------------------------------------------------------------------------------

set +e

# ---------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------

# API endpoint for SDK config (includes iOS query schemes under appInstallStatus.iOS)
readonly API_ENDPOINT="https://ads.pubmatic.com/openwrapsdk/sdkconfig.json"

# Key name in Info.plist
readonly PLIST_KEY="LSApplicationQueriesSchemes"

# iOS limits LSApplicationQueriesSchemes to 50 entries (ignored beyond that).
readonly MAX_QUERY_SCHEMES=50

# PlistBuddy path
readonly PLIST_BUDDY="/usr/libexec/PlistBuddy"

# Log prefix (same style as dSYMScript.sh: [OpenWrapSDK - <script>]:)
readonly LOG_PREFIX="[OpenWrapSDK - POBAddQuerySchemesScript]:"

# Global array to hold schemes
SCHEMES_LIST=()

# Global array to hold required schemes fetched from API
REQUIRED_SCHEMES=()

# ---------------------------------------------------------------------------------------
# Utility Functions
# ---------------------------------------------------------------------------------------

# Log a failure message silently; does not fail the build (caller exits 0).
#
# Arguments:
#   $1 - Message to display
log_error() {
    echo "${LOG_PREFIX} Error - $1" >&2
}

# Log line (stderr — avoids polluting stdout when used with $(...) capture)
#
# Arguments:
#   $1 - Message to display (same line format as dSYMScript.sh echo lines)
print_info() {
    echo "${LOG_PREFIX} $1" >&2
}

# ---------------------------------------------------------------------------------------
# Environment Setup Functions
# ---------------------------------------------------------------------------------------

# Determine the path to the Info.plist file using Xcode environment variables
#
# Returns:
#   Echoes ONLY the resolved path on stdout (for info_plist=$(determine_info_plist_path)).
#   Progress lines use print_info → stderr.
#   Return 0 and path on success; return 1 and empty stdout if unresolved.
determine_info_plist_path() {
    local info_plist=""

    # Step 1: Check if TARGET_BUILD_DIR and INFOPLIST_PATH are set
    if [ -n "${TARGET_BUILD_DIR}" ] && [ -n "${INFOPLIST_PATH}" ]; then
        info_plist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
        print_info "Info.plist path resolved to ${info_plist}"
        echo "${info_plist}"
        return 0
    fi

    log_error "Could not resolve Info.plist path. Use this Run Script on an app target in Xcode Build Phases."
    echo ""
    return 1
}

# Validate environment: check for PlistBuddy tool and Info.plist file existence
#
# Arguments:
#   $1 - Path to Info.plist file
# Returns:
#   0 if OK; 1 if update cannot proceed (error logged).
validate_environment() {
    local info_plist="$1"

    # Step 1: Check PlistBuddy exists
    if [ ! -f "${PLIST_BUDDY}" ]; then
        log_error "PlistBuddy not found at ${PLIST_BUDDY}. Install or repair Xcode (Command Line Tools)."
        return 1
    fi

    # Step 2: Check Info.plist exists
    if [ ! -f "${info_plist}" ]; then
        log_error "Info.plist file not found at ${info_plist}. Move this Run Script after the app bundle is produced (e.g. after Copy Bundle Resources)."
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------------------
# API Fetch Functions
# ---------------------------------------------------------------------------------------

# Parse sdkconfig.json: collect every string from all arrays under appInstallStatus:iOS
# Emits one scheme per line.
#
# Arguments:
#   $1 - JSON response string
# Returns:
#   Echoes newline-separated list of schemes (may be empty)
# Exits:
#   Always 0. Empty output means no schemes (invalid JSON, missing iOS, plutil failure, etc.).
parse_sdkconfig_ios_schemes() {
    local json_response="$1"
    local tmp_json tmp_plist schemes_list pb_out pb_st

    if ! command -v plutil &> /dev/null; then
        return 0
    fi

    # Step 1: Create a temporary file which will hold the JSON response
    tmp_json=$(mktemp -t pob_sdkconfig_json) || return 0
    tmp_plist=$(mktemp -t pob_sdkconfig_plist) || {
        rm -f "${tmp_json}"
        return 0
    }

    # Step 2: Write the JSON response to the temporary file
    printf '%s' "${json_response}" > "${tmp_json}" || {
        rm -f "${tmp_json}" "${tmp_plist}"
        return 0
    }

    # Step 3: Convert the downloaded JSON to XML plist format to enable parsing with PlistBuddy
    if ! plutil -convert xml1 "${tmp_json}" -o "${tmp_plist}" 2>/dev/null; then
        rm -f "${tmp_json}" "${tmp_plist}"
        return 0
    fi
    rm -f "${tmp_json}"

    set +e
    # Step 4: Extract the iOS section under appInstallStatus using PlistBuddy. If not found, pb_out is empty.
    pb_out=$(${PLIST_BUDDY} -c "Print :appInstallStatus:iOS" "${tmp_plist}" 2>/dev/null)
    pb_st=$?
    rm -f "${tmp_plist}"

    # Missing :appInstallStatus:iOS — not an error; no schemes from API
    if [ "${pb_st}" -ne 0 ]; then
        return 0
    fi

    # Step 5: Process the PlistBuddy output to extract the schemes

    # PlistBuddy "Print" of a dict: array entries are unindented lines without '='
    # The following pipeline processes the PlistBuddy output (pb_out) for the :appInstallStatus:iOS dictionary,
    # which consists of one or more arrays. It performs these steps:
    # - Removes lines indicating 'Dict' or 'Array' (structure headers)
    # - Removes closing curly braces (end of dictionary/array)
    # - Excludes lines with '=' as they represent key-value pairs, not array items
    # - Trims leading and trailing whitespace
    # - Removes any resulting empty lines
    # - Sorts the list of schemes uniquely
    # This results in a newline-separated list of all unique scheme strings under appInstallStatus:iOS arrays.
    schemes_list=$(printf '%s\n' "${pb_out}" | \
        grep -v '^[[:space:]]*Dict' | \
        grep -v '^[[:space:]]*Array' | \
        grep -v '^[[:space:]]*}[[:space:]]*$' | \
        grep -v '=' | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        grep -v '^$' | sort -u)

    printf '%s' "${schemes_list}"
}

# Fetch required schemes from API endpoint
# Populates the global REQUIRED_SCHEMES array with schemes from the API
# Uses only built-in macOS tools (curl, grep, sed, awk, tr)
#
# Returns:
#   Populates the global REQUIRED_SCHEMES array (may remain empty)
# Exits:
#   0 always. Empty REQUIRED_SCHEMES means skip plist updates (network error, status code not in 2xx range, empty body, invalid JSON, no iOS schemes).
fetch_required_schemes_from_api() {
    # Step 1: Check if curl is available (built into macOS)
    if ! command -v curl &> /dev/null; then
        log_error "curl command not found in PATH."
        return 0
    fi

    # Step 2: Fetch JSON response from API
    local response
    local http_code

    print_info "Fetching query URL scheme list from PubMatic..."
    response=$(curl -s -w "\n%{http_code}" --max-time 10 "${API_ENDPOINT}" 2>&1)
    local curl_st=$?

    if [ "${curl_st}" -ne 0 ]; then
        print_info "Failed to fetch query URL scheme list (network or timeout error)."
        return 0
    fi

    # Step 3: Extract HTTP status code (last line)
    http_code=$(echo "${response}" | tail -n1)

    # Step 4: Extract JSON body (all lines except last)
    response=$(echo "${response}" | sed '$d')

    # Step 5: Proceed only if HTTP status code is in the 2xx success range; otherwise, skip further processing
    if [ "${http_code}" -lt 200 ] || [ "${http_code}" -gt 299 ]; then
        print_info "Error - server returned HTTP ${http_code}."
        return 0
    fi

    # Step 6: Check if the response is empty
    if [ -z "${response}" ]; then
        print_info "Received empty response from server. Skipping query URL scheme update."
        return 0
    fi

    # Step 7: Parse the JSON response to extract the schemes
    print_info "Parsing query URL scheme list..."
    # Parse JSON: unique schemes from appInstallStatus.iOS (empty on invalid JSON / wrong shape)
    local schemes_list
    schemes_list=$(parse_sdkconfig_ios_schemes "${response}")

    # Step 8: Populate REQUIRED_SCHEMES array
    if [ -n "${schemes_list}" ]; then
        local IFS=$'\n'
        local schemes_array=($(echo "${schemes_list}"))
        # Iterate through each scheme in the parsed schemes array,
        # trim any leading/trailing whitespace and, if the resulting string is non-empty,
        # add it to the REQUIRED_SCHEMES global array.
        for scheme in "${schemes_array[@]}"; do
            scheme=$(echo "${scheme}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            if [ -n "${scheme}" ]; then
                REQUIRED_SCHEMES+=("${scheme}")
            fi
        done
    fi

    # Step 9: Check if the REQUIRED_SCHEMES array is empty
    if [ ${#REQUIRED_SCHEMES[@]} -eq 0 ]; then
        print_info "No query URL schemes returned."
    else
        print_info "Fetched ${#REQUIRED_SCHEMES[@]} query URL scheme(s) from PubMatic API endpoint."
    fi

    return 0
}

# ---------------------------------------------------------------------------------------
# Scheme Reading Functions
# ---------------------------------------------------------------------------------------

# Read existing schemes from Info.plist into the global SCHEMES_LIST array
# Also prints information about existing schemes
#
# Arguments:
#   $1 - Path to Info.plist file
# Returns:
#   Populates the global SCHEMES_LIST array with existing schemes
read_existing_schemes() {
    local info_plist="$1"
    local count=0

    print_info "Reading existing query URL schemes from Info.plist..."

    # Step 1: Check if key `LSApplicationQueriesSchemes` exists and get count of query URL schemes
    if ${PLIST_BUDDY} -c "Print :${PLIST_KEY}" "${info_plist}" >/dev/null 2>&1; then
        count=$(${PLIST_BUDDY} -c "Print :${PLIST_KEY}" "${info_plist}" 2>/dev/null | grep -E '^[[:space:]]+[^=]' | wc -l)

        if [ "${count}" -gt 0 ]; then
            print_info "Found ${count} existing query URL scheme(s) in Info.plist."
            # Read each scheme into global array
            for ((i=0; i<count; i++)); do
                local scheme=$(${PLIST_BUDDY} -c "Print :${PLIST_KEY}:${i}" "${info_plist}" 2>/dev/null || echo "")
                if [ -n "${scheme}" ]; then
                    SCHEMES_LIST+=("${scheme}")
                fi
            done
        else
            print_info "Query URL scheme list in Info.plist is empty."
        fi
    else
        print_info "No query URL schemes key in Info.plist yet."
    fi
}

# ---------------------------------------------------------------------------------------
# Scheme Processing Functions
# ---------------------------------------------------------------------------------------

# Returns 0 if candidate is not in SCHEMES_LIST (caller may append), 1 if already present.
# Uses global SCHEMES_LIST.
scheme_is_absent_from_list() {
    local candidate="$1"
    local existing
    for existing in "${SCHEMES_LIST[@]}"; do
        if [ "${existing}" = "${candidate}" ]; then
            return 1
        fi
    done
    return 0
}

# Creates the combined unique query URL schemes list in the global SCHEMES_LIST.
# Expects SCHEMES_LIST to already contain schemes read from Info.plist (plist order preserved).
# Appends each entry from REQUIRED_SCHEMES (API order) only if absent and non-empty, until
# SCHEMES_LIST reaches MAX_QUERY_SCHEMES. Caller should ensure count is below the cap first.
# Uses globals SCHEMES_LIST, REQUIRED_SCHEMES.
#
# Arguments:
#   None
# Returns:
#   0 always. Mutates SCHEMES_LIST in place.
create_combined_unique_schemes_list() {
    local scheme
    local cap="${MAX_QUERY_SCHEMES}"

    # Append API-required schemes after existing plist entries: preserve REQUIRED_SCHEMES order,
    # skip empties and duplicates, stop at the iOS LSApplicationQueriesSchemes cap.
    for scheme in "${REQUIRED_SCHEMES[@]}"; do
        # Step 1: Check if the number of schemes in Info.plist is already at or above the iOS limit (maximum 50 schemes)
        # If the number of schemes in Info.plist is already at or above the iOS limit (maximum 50 schemes),
        # do not change the list or merge in any schemes from the API.
        [ ${#SCHEMES_LIST[@]} -ge "${cap}" ] && break
        # Step 2: Check if the scheme is empty
        [ -z "${scheme}" ] && continue

        # Step 3: Check if the scheme is already present in SCHEMES_LIST
        if scheme_is_absent_from_list "${scheme}"; then
            # Step 4: Add the scheme to SCHEMES_LIST
            SCHEMES_LIST+=("${scheme}")
        fi
    done

    print_info "Combined unique query URL scheme list contains ${#SCHEMES_LIST[@]} scheme(s)."
}

# ---------------------------------------------------------------------------------------
# Info.plist Update Functions
# ---------------------------------------------------------------------------------------

# Update Info.plist with the complete list of URL schemes
# Replaces existing array with new one containing all unique schemes from global SCHEMES_LIST
#
# Arguments:
#   $1 - Path to Info.plist file
# Returns:
#   0 if Info.plist was updated; 1 on failure.
update_plist_with_schemes() {
    local info_plist="$1"
    local backup

    # Step 1: Create a temporary file which will hold the backup of Info.plist
    backup=$(mktemp -t pob_infoplist_bak) || {
        log_error "Could not create temporary file which will hold the backup of Info.plist."
        return 1
    }

    # Step 2: Copy the Info.plist to the temporary file
    if ! cp "${info_plist}" "${backup}" 2>/dev/null; then
        rm -f "${backup}"
        log_error "Could not back up Info.plist to the temporary file."
        return 1
    fi

    # Function to restore Info.plist from the backup
    pob_restore_infoplist() {
        cp "${backup}" "${info_plist}" 2>/dev/null || true
        rm -f "${backup}"
    }

    print_info "Writing ${#SCHEMES_LIST[@]} query URL scheme(s) to Info.plist..."

    # Step 3: Check if `LSApplicationQueriesSchemes` key already exists and delete it
    if ${PLIST_BUDDY} -c "Print :${PLIST_KEY}" "${info_plist}" >/dev/null 2>&1; then
        if ! ${PLIST_BUDDY} -c "Delete :${PLIST_KEY}" "${info_plist}" 2>/dev/null; then
            log_error "Failed to remove existing query URL schemes from Info.plist. Info.plist unchanged."
            rm -f "${backup}"
            return 1
        fi
    fi

    # Step 4: Add new `LSApplicationQueriesSchemes` key
    if ! ${PLIST_BUDDY} -c "Add :${PLIST_KEY} array" "${info_plist}" 2>/dev/null; then
        log_error "Failed to create query URL schemes array in Info.plist. Restoring backup."
        pob_restore_infoplist
        print_info "Info.plist restored from backup."
        return 1
    fi

    # Step 5: Add combined query URL schemes to Info.plist
    local index=0
    for scheme in "${SCHEMES_LIST[@]}"; do
        if [ -n "${scheme}" ]; then
            if ! ${PLIST_BUDDY} -c "Add :${PLIST_KEY}:${index} string ${scheme}" "${info_plist}" 2>/dev/null; then
                log_error "Failed to add query URL scheme \"${scheme}\" to Info.plist. Restoring backup."
                pob_restore_infoplist
                print_info "Info.plist restored from backup."
                return 1
            fi
            index=$((index + 1))
        fi
    done

    # Step 6: Remove the temporary file
    rm -f "${backup}"
    print_info "Info.plist updated with query URL schemes."
    return 0
}

# ---------------------------------------------------------------------------------------
# Main Workflow Function
# ---------------------------------------------------------------------------------------

# Main execution flow - orchestrates all the steps
# Always exits 0 so the Xcode build never fails because of this script.
main() {
    # Step 1: Check if running in Release configuration
    if [ -n "${CONFIGURATION}" ] && [ "${CONFIGURATION}" != "Release" ]; then
        print_info "POBAddQuerySchemesScript.sh will update query schemes only for Release build configuration."
        print_info "Current configuration: ${CONFIGURATION}"
        print_info "Skipping URL schemes update."
        exit 0
    fi

    print_info "Running query URL scheme update script for Release build"


    # Step 2: Determine and validate Info.plist path
    local info_plist
    info_plist=$(determine_info_plist_path)
    if [ -z "${info_plist}" ]; then
        print_info "Query URL scheme update skipped."
        exit 0
    fi

    if ! validate_environment "${info_plist}"; then
        print_info "Query URL scheme update skipped."
        exit 0
    fi

    print_info "Validation completed. Proceeding to fetch required schemes from API."

    # Step 3: Fetch required schemes from API
    # Fetch query schemes from API endpoint, parse, and populate global REQUIRED_SCHEMES array
    fetch_required_schemes_from_api

    # If query schemes are not fetched or parsed, it's a failure case; return safely.
    if [ ${#REQUIRED_SCHEMES[@]} -eq 0 ]; then
        exit 0
    fi

    print_info "Required schemes fetched from API. Proceeding to read existing schemes from Info.plist."

    # Step 4: Read existing schemes from Info.plist into global array
    read_existing_schemes "${info_plist}"

    if [ ${#SCHEMES_LIST[@]} -ge "${MAX_QUERY_SCHEMES}" ]; then
        print_info "Info.plist already lists ${#SCHEMES_LIST[@]} query URL scheme(s) (iOS allows at most ${MAX_QUERY_SCHEMES}); skipping injecting new schemes."
        exit 0
    fi

    print_info "Existing schemes read from Info.plist. Proceeding to build combined unique schemes list."

    # Step 5: Create combined unique schemes list (plist entries + API entries, capped)
    create_combined_unique_schemes_list

    print_info "Combined unique schemes list ready. Proceeding to update Info.plist."

    # Step 6: Write SCHEMES_LIST to Info.plist
    if ! update_plist_with_schemes "${info_plist}"; then
        print_info "Query URL scheme update did not complete."
        exit 0
    fi

    print_info "Query URL scheme update finished. Info.plist contains ${#SCHEMES_LIST[@]} scheme(s)."
    exit 0
}

# ---------------------------------------------------------------------------------------
# Script Entry Point
# ---------------------------------------------------------------------------------------
main
exit 0
