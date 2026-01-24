SHELL                   := zsh
SCRIPT_NAME             := screenshot-tagger
export BIN_DIR          := $(HOME)/.local/bin/$(SCRIPT_NAME)
export ARG_FILES_DIR    := $(HOME)/.local/share/exiftool

ENGINE_NAME             := tagger-engine
export WATCHER_NAME     := screenshot-watcher

PLIST_NAME_BASE         := screenshot_tagger.plist
PLIST_NAME_TEMPLATE     := $(PLIST_NAME_BASE).template
PLIST_NAME              := me.$(USER).$(PLIST_NAME_BASE)

export LOG_FILE         := $(HOME)/Library/Logs/me.$(USER).$(WATCHER_NAME).log
export TMPDIR           := /Volumes/Workbench/
export INPUT_DIR        := $(TMPDIR)$(SCRIPT_NAME)
export OUTPUT_DIR       := $(HOME)/MyFiles/Pictures/Screenshots

export HW_MODEL         := $$(system_profiler SPHardwareDataType | sed -En 's/^.*Model Name: //p')

export EXECUTION_DELAY  :=0.1
export THROTTLE_INTERVAL:=2

export LOCK_PATH        := $(TMPDIR)$(WATCHER_NAME).lock

INSTALL                 := install -pv

.PHONY: all install start stop uninstall clean

all: install start

install:
	@{ [[ -e $(BIN_DIR) && ! -d $(BIN_DIR) ]] && rm $(BIN_DIR) } || true
	@mkdir -p $(BIN_DIR)
	@mkdir -p ~/Library/Logs

	@$(INSTALL) -m 755 $(ENGINE_NAME).zsh  $(BIN_DIR)/$(ENGINE_NAME)
	@zcompile -U $(BIN_DIR)/$(ENGINE_NAME)

	@$(INSTALL) -m 755 $(WATCHER_NAME).zsh $(BIN_DIR)/$(WATCHER_NAME)
	@zcompile -U $(BIN_DIR)/$(WATCHER_NAME)

start: $(PLIST_NAME_TEMPLATE)
	@content=$$(<$<); print -r -- "$${(e)content}" > $(PLIST_NAME)
	@mv $(PLIST_NAME) ~/Library/LaunchAgents/
	launchctl bootstrap gui/$$(id -u) $(PLIST_NAME)

stop:
	-launchctl bootout gui/$$(id -u) $(PLIST_NAME)
	-rm -f ~/Library/LaunchAgents/$(PLIST_NAME)

uninstall: stop
	rm -rf $(BIN_DIR)

log:
	open $(LOG_FILE)

delete-log:
	rm $(LOG_FILE)
