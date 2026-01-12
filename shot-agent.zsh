#!/usr/bin/env -S zsh -f
# A script for preparing `shot-processor.zsh`. It will be called by `launchd`

setopt ERR_EXIT
setopt NO_UNSET

readonly SCREENSHOTS_DIR=${HOME}/MyFiles/Pictures/Screenshots
readonly PIPE=${SCREENSHOTS_DIR}/tag_and_rename.pipe

readonly HOMEBREW_PREFIX=/opt/homebrew

readonly EXECUTABLE_DIR=${HOME}/.local/bin/tag_and_rename
readonly TAG_FILES_DIR=${HOME}/.local/share/exiftool

float -r EXECUTION_DELAY=0.5

export -Ua path
path=("$EXECUTABLE_DIR" "${HOMEBREW_PREFIX}/bin" "${HOMEBREW_PREFIX}/opt/libarchive/bin" ${==path})

################################################################################

if [[ -p $PIPE ]]; then
    echo "Pipe '${PIPE}' exists; Folder action already in progress" 1>&2
    exit 1
fi
# Taking multiple screenshots in succession causes the Folder Action to trigger
# the same amount of times. Checking for this temporary pipe in the `if`
# statement above ensures that only the first instance of the Folder Action
# executes the rest of the script body.
mkfifo "$PIPE" && trap 'rm "$PIPE"' EXIT

sleep $EXECUTION_DELAY # Give time for all screenshots to be written to disk

processor.sh --verbose --input "${SCREENSHOTS_DIR}/.tmp" --output "$SCREENSHOTS_DIR"\
    --tag "${TAG_FILES_DIR}/charlesmc.args"\
    --tag "${TAG_FILES_DIR}/screenshot.args"
