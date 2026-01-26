export HOMEBREW_PREFIX  := $(shell brew --prefix)
export SHELL            := $(HOMEBREW_PREFIX)/bin/zsh
export SCRIPT_NAME      := screenshot-tagger

export BIN_DIR          := $(HOME)/.local/bin/$(SCRIPT_NAME)
export ARG_FILES_DIR    := $(HOME)/.local/share/exiftool
LOG_DIR                 := $(HOME)/Library/Logs
export LOG_FILE         := $(LOG_DIR)/me.$(USER).$(SCRIPT_NAME).log

ENGINE_NAME             := tagger-engine
export WATCHER_NAME     := screenshot-watcher

PLIST_BASE              := screenshot_tagger.plist
PLIST_NAME              := me.$(USER).$(PLIST_BASE)
PLIST_PATH              := $(HOME)/Library/LaunchAgents/$(PLIST_NAME)

ROOT_DIR                := /Volumes/Workbench
export TMPDIR           := $(ROOT_DIR)/$(SCRIPT_NAME)/tmp
export TMPPREFIX        := $(TMPDIR)/zsh-
export INPUT_DIR        := $(ROOT_DIR)/Screenshots
export OUTPUT_DIR       := $(HOME)/MyFiles/Pictures/Screenshots
export LOCK_PATH        := $(TMPDIR)/.lock

export HW_MODEL         := $(shell system_profiler SPHardwareDataType | sed -En 's/^.*Model Name: //p')

export EXECUTION_DELAY  :=0.1
export THROTTLE_INTERVAL:=1

INSTALL                 := install -pv -m 755

.PHONY: all install start stop uninstall reinstall clean

all: start

install: $(BIN_DIR)/$(ENGINE_NAME) $(BIN_DIR)/$(WATCHER_NAME)

$(BIN_DIR)/%: %.zsh | $(BIN_DIR) $(LOG_DIR) $(TMPDIR)
	@$(INSTALL) $< $@
	@zcompile -U $@

$(BIN_DIR):
	@if [[ -e $@ && ! -d $@ ]]; then \
		rm $@; \
	fi
	@mkdir -p $@

start: $(PLIST_PATH) stop install
	launchctl bootstrap gui/$(shell id -u) $<

$(PLIST_PATH): $(PLIST_BASE).template
	@content=$$(<$<); print -r -- "$${(e)content}" >| $@

stop:
	-launchctl bootout gui/$(shell id -u) $(PLIST_PATH) 2>/dev/null

clean:
	rm -f $(BIN_DIR)/*.zwc
	rm -f $(TMPDIR)/*

uninstall: stop
	rm -rf $(BIN_DIR)
	rm -f $(PLIST_PATH)

status:
	@launchctl list | grep $(USER) 2>/dev/null

open-log:
	@open $(LOG_FILE)

clear-log:
	@print -- >| $(LOG_FILE)
