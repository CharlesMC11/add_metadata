_sst_on_exit() {
  _cmc_log DEBUG 'Moving temporary logs to system log'

  exec {log_fd}>&-

  if [[ -s $LOG_FILE ]]; then
    print -- "$mapfile[$LOG_FILE]" >>! "$SYSTEM_LOG"
  fi
}
