.DELETE_ON_ERROR:

export SHELL            := $(shell which zsh)
.SHELLFLAGS             := -fc

CONFIGS                 := Makefile

export HOMEBREW_PREFIX  := $(shell brew --prefix)
export SCRIPT_NAME      := screenshot-tagger

ROOT_DIR                := /Volumes/Workbench
WORK_DIR                := $(ROOT_DIR)/$(SCRIPT_NAME)

export BIN_DIR          := $(WORK_DIR)
export ARG_FILES_DIR    := $(HOME)/.local/share/exiftool
LOG_DIR                 := $(HOME)/Library/Logs
export LOG_FILE         := $(LOG_DIR)/me.$(USER).$(SCRIPT_NAME).log

export TMPDIR           := $(WORK_DIR)/tmp
export TMPPREFIX        := $(TMPDIR)/zsh-
export INPUT_DIR        := $(ROOT_DIR)/Screenshots
export OUTPUT_DIR       := $(HOME)/MyFiles/Pictures/Screenshots
export LOCK_PATH        := $(TMPDIR)/.lock

ENGINE_NAME             := tagger-engine
export WATCHER_NAME     := screenshot-watcher

PLIST_BASE              := screenshot_tagger.plist
PLIST_NAME              := me.$(USER).$(PLIST_BASE)
PLIST_PATH              := $(HOME)/Library/LaunchAgents/$(PLIST_NAME)

SCREENCAPTURE_PREF      := com.apple.screencapture location

export HW_MODEL         := $(shell system_profiler SPHardwareDataType | \
							sed -En 's/^.*Model Name: //p')

export EXECUTION_DELAY  :=0.1
export THROTTLE_INTERVAL:=1

INSTALL                 := install -pv -m 755
UNINSTALLER             := $(BIN_DIR)/uninstall

.PHONY: all install start stop uninstall clean status open-log clean-log check-ram-disk

all: start

check-ram-disk:
# return 78: BSD EX_CONFIG
	@if [[ ! -d "$(ROOT_DIR)" ]]; then \
		print -- '"$(ROOT_DIR)" is not loaded'; \
		exit 78; \
	fi

$(TMPDIR) $(INPUT_DIR) $(LOG_DIR):
	mkdir -p "$@"

$(BIN_DIR)/.dirstamp:
	@if [[ -e "$(BIN_DIR)" && ! -d "$(BIN_DIR)" ]]; then \
		rm "$(BIN_DIR)"; \
	fi
	@mkdir -p "$(BIN_DIR)" && touch "$@"

$(BIN_DIR)/%: %.zsh $(CONFIGS) | $(BIN_DIR)/.dirstamp
	@$(INSTALL) "$<" "$@"
	@zcompile -U "$@"

$(PLIST_PATH): $(PLIST_BASE).template Makefile
	@content="$$(<$<)"; print -r -- "$${(e)content}" >| "$@"

$(UNINSTALLER): $(CONFIGS) | $(BIN_DIR)/.dirstamp
	@print -l -- \
		'#!/usr/bin/env sh' \
		'launchctl bootout gui/$(shell id -u) "$(PLIST_PATH)"' \
		'rm -f "$(PLIST_PATH)"' \
		'rm -rf "$(BIN_DIR)"' \
		'defaults delete $(SCREENCAPTURE_PREF)' \
		'killall SystemUIServer' > "$@"
	@chmod 755 "$@"

install: check-ram-disk $(BIN_DIR)/$(ENGINE_NAME) $(BIN_DIR)/$(WATCHER_NAME) \
	$(UNINSTALLER) | $(TMPDIR) $(INPUT_DIR) $(LOG_DIR)

start: $(PLIST_PATH) install
	@launchctl bootout gui/$(shell id -u) "$(PLIST_PATH)" 2>/dev/null || true
	launchctl bootstrap gui/$(shell id -u) "$<"
	defaults write $(SCREENCAPTURE_PREF) -string "$(INPUT_DIR)"
	@killall SystemUIServer

stop:
	-launchctl bootout gui/$(shell id -u) "$(PLIST_PATH)" 2>/dev/null
	-defaults delete $(SCREENCAPTURE_PREF) 2>/dev/null
	@killall SystemUIServer

uninstall: stop
	rm -f "$(PLIST_PATH)"
	rm -rf "$(BIN_DIR)"

clean:
	rm -f "$(BIN_DIR)"/*.zwc
	rm -f "$(TMPDIR)"/*

status:
	@launchctl list | grep "$(USER)"

open-log:
	@open "$(LOG_FILE)"

clean-log:
	@print -- >| "$(LOG_FILE)"
