SHELL         := zsh
SCRIPT_NAME   := shot-tagger
BIN_DIR       := ~/.local/bin/$(SCRIPT_NAME)

SRC_PROCESSOR := shot-processor.zsh
SRC_AGENT     := shot-agent.zsh

INSTALL       := install -vl as

.PHONY: all install compile load unload clean

all: compile install

compile: $(SRC_PROCESSOR).zwc $(SRC_AGENT).zwc

%.zwc: %
	zcompile $<

install: compile
	@echo "Installing to '$(BIN_DIR)'"
	@if [[ -e $(BIN_DIR) && ! -d $(BIN_DIR) ]]; then\
		rm $(BIN_DIR);\
	fi
	@mkdir -p $(BIN_DIR)

	$(INSTALL) -m 755 $(SRC_PROCESSOR)     $(BIN_DIR)
	$(INSTALL) -m 755 $(SRC_AGENT)         $(BIN_DIR)
	$(INSTALL) -m 644 $(SRC_PROCESSOR).zwc $(BIN_DIR)
	$(INSTALL) -m 644 $(SRC_AGENT).zwc     $(BIN_DIR)

load: me.charlesmc.shot_tagger.plist
	@echo 'Loading launchd plist...'
	$(INSTALL) -m 644 $< ~/Library/LaunchAgents/
	launchctl load -w $<

unload: me.charlesmc.shot_tagger.plist
	@echo 'Unloading launchd plist...'
	launchctl unload -w $<
	rm -f ~/Library/LaunchAgents/$<

clean:
	@echo 'Removing installed files...'
	rm -rf $(BIN_DIR) *.zwc