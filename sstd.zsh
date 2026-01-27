#!/opt/homebrew/bin/zsh -f
# A script for preparing `sst`. It will be called by `launchd`

setopt CHASE_LINKS
setopt ERR_EXIT
setopt NO_UNSET
setopt WARN_CREATE_GLOBAL
setopt NO_NOTIFY
setopt NO_BEEP

zmodload zsh/files
zmodload zsh/system

source "${BIN_DIR}/sst"

################################################################################

integer fd
exec {fd}>|"${LOCK_PATH}" && trap 'exec {fd}>&-' EXIT

if zsystem flock -t 0 -f $fd "${LOCK_PATH}"; then
  _sst::log INFO "Lock created in '${LOCK_PATH:h}/'; starting..."
else
  # return 75: BSD EX_TEMPFAIL
  _sst::err 75 "Lock exists in '${LOCK_PATH:h}/'; exiting..."
fi

sleep $EXECUTION_DELAY  # Give time for all screenshots to be written to disk

msg=$(sst --verbose --input "$INPUT_DIR" --output "$OUTPUT_DIR" --model "${HW_MODEL}" \
  -@ "${ARG_FILES_DIR}/charlesmc.args" -@ "${ARG_FILES_DIR}/screenshot.args")

integer -r status_code=$?
if (( status_code == 0 )); then
  subtitle=Success
  sound=Glass
else
  subtitle="Failure (Exit Code: $status_code)"
  sound=Basso
fi

print -- "${=msg}"
osascript <<EOF
  display notification "${msg#*: }" \
  with title "Screenshot Tagger" \
  subtitle "${subtitle}" \
  sound name "${sound}"
EOF
