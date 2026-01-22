#!/usr/bin/env -S zsh -f
# A script for preparing `tagger-engine`. It will be called by `launchd`

setopt CHASE_LINKS
setopt ERR_EXIT
setopt NO_UNSET
setopt WARN_CREATE_GLOBAL
setopt NO_NOTIFY
setopt NO_BEEP

zmodload zsh/files

readonly SCRIPT_NAME=${0:t:r}

readonly EXECUTABLE_DIR=${HOME}/.local/bin/screenshot-tagger
readonly ARG_FILES_DIR=${HOME}/.local/share/exiftool

if [[ -f ${EXECUTABLE_DIR}/config.zsh ]]; then
    source "${EXECUTABLE_DIR}/config.zsh"
else
    print -u 2 -- 'Environment file not found; exiting...'
    exit $EX_NOINPUT
fi

readonly LOCK_PATH="${TMPDIR}${SCRIPT_NAME}.lock"

float -r EXECUTION_DELAY=1

readonly HOMEBREW_PREFIX=/opt/homebrew

export -Ua path
path=(
    "$EXECUTABLE_DIR"
    "${HOMEBREW_PREFIX}/bin"
    ${==path}
)

################################################################################

# Taking multiple screenshots in succession causes `launchd` to trigger the same
# amount of times. Checking for this lock ensures that only the first instance
# of the script executes the rest of the script body.
if mkdir -m 200 "$LOCK_PATH" 2>/dev/null; then
    trap 'rmdir "$LOCK_PATH"' EXIT
    print -- "Created lock in '${LOCK_PATH:h}/'"
else
    print -u 2 -- "Lock exists in '${LOCK_PATH:h}/'; exiting..."
    exit $EX_TEMPFAIL
fi

sleep $EXECUTION_DELAY # Give time for all screenshots to be written to disk

source "${EXECUTABLE_DIR}/tagger-engine"
local engine_output
engine_output=$(tagger-engine::main --input "$INPUT_DIR" --output "$OUTPUT_DIR"\
    -@ "${ARG_FILES_DIR}/charlesmc.args" -@ "${ARG_FILES_DIR}/screenshot.args")

integer -r exit_status=$?
if (( exit_status == 0 )); then
    subtitle=Success
    sound=Glass
else
    subtitle="Failure (Error: $exit_status)"
    sound=Basso
fi

print -- $engine_output

readonly msg=$(print -- "$engine_output" | tail -n 1)
osascript <<EOF
    display notification "${msg}" with title "Screenshot Tagger" subtitle "${subtitle}" sound name "${sound}"
EOF
