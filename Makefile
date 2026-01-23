SHELL               := zsh
SCRIPT_NAME         := screenshot-tagger
export BIN_DIR      := $(HOME)/.local/bin/$(SCRIPT_NAME)
export ARG_FILES_DIR:= $(HOME)/.local/share/exiftool

ENGINE_NAME         := tagger-engine
export WATCHER_NAME := screenshot-watcher

PLIST_NAME_BASE     := screenshot_tagger.plist
PLIST_NAME_TEMPLATE := $(PLIST_NAME_BASE).template
PLIST_NAME          := me.$(USER).$(PLIST_NAME_BASE)

export LOG_FILE     := $(HOME)/Library/Logs/me.$(USER).$(WATCHER_NAME).log
export TMPDIR       := /Volumes/Workbench/
export INPUT_DIR    := $(TMPDIR)$(SCRIPT_NAME)
export OUTPUT_DIR   := $(HOME)/MyFiles/Pictures/Screenshots

export HW_MODEL     := $(shell system_profiler SPHardwareDataType | sed -En 's/^.*Model Name: //p')

export EXECUTION_DELAY:=0.1
export THROTTLE_INTERVAL:=2

export LOCK_PATH    := $(TMPDIR)$(WATCHER_NAME).lock

INSTALL             := install -v

.PHONY: all install compile start stop uninstall clean

all: compile install start

install: compile
	@print -- "Installing to '$(BIN_DIR)'"
	@if [[ -e $(BIN_DIR) && ! -d $(BIN_DIR) ]]; then\
		rm $(BIN_DIR);\
	fi
	@mkdir -p $(BIN_DIR)
	@mkdir -p ~/Library/Logs

	@$(INSTALL) -m 755 $(ENGINE_NAME).zsh      $(BIN_DIR)/$(ENGINE_NAME)
	@$(INSTALL) -m 444 $(ENGINE_NAME).zsh.zwc  $(BIN_DIR)/$(ENGINE_NAME).zwc

	@$(INSTALL) -m 755 $(WATCHER_NAME).zsh     $(BIN_DIR)/$(WATCHER_NAME)
	@$(INSTALL) -m 444 $(WATCHER_NAME).zsh.zwc $(BIN_DIR)/$(WATCHER_NAME).zwc

compile: $(ENGINE_NAME).zwc $(WATCHER_NAME).zwc

start: $(PLIST_NAME)
	@$(INSTALL) -m 400 $(PLIST_NAME) ~/Library/LaunchAgents/
	launchctl bootstrap gui/$(shell id -u) $(PLIST_NAME)

$(PLIST_NAME): $(PLIST_NAME_TEMPLATE)
	@zsh -fc 'content=$$(<$<); print -r -- "$${(e)content}"' > $@

stop: $(PLIST_NAME)
	-launchctl bootout gui/$(shell id -u) $(PLIST_NAME)
	-rm -f ~/Library/LaunchAgents/$(PLIST_NAME)

uninstall: stop
	@print -- "Uninstalling '$(BIN_DIR)'..."
	rm -rf $(BIN_DIR)

clean:
	-rm -f *.zwc
	-rm -f *.plist

%.zwc: %.zsh
	zsh -n $<
	zcompile -U $<

log:
	open $(LOG_FILE)

delete-log:
	rm $(LOG_FILE)
