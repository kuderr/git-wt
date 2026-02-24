PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
BASH_COMPLETIONS_DIR ?= $(PREFIX)/share/bash-completion/completions
ZSH_COMPLETIONS_DIR ?= $(PREFIX)/share/zsh/site-functions

.PHONY: install uninstall install-completions uninstall-completions lint test

install: install-completions
	@mkdir -p $(BINDIR)
	@cp bin/git-wt $(BINDIR)/git-wt
	@chmod +x $(BINDIR)/git-wt
	@echo "Installed git-wt to $(BINDIR)/git-wt"

install-completions:
	@mkdir -p $(BASH_COMPLETIONS_DIR)
	@cp completions/git-wt.bash $(BASH_COMPLETIONS_DIR)/git-wt
	@mkdir -p $(ZSH_COMPLETIONS_DIR)
	@cp completions/_git-wt $(ZSH_COMPLETIONS_DIR)/_git-wt
	@echo "Installed completions"

uninstall: uninstall-completions
	@rm -f $(BINDIR)/git-wt
	@echo "Uninstalled git-wt from $(BINDIR)"

uninstall-completions:
	@rm -f $(BASH_COMPLETIONS_DIR)/git-wt
	@rm -f $(ZSH_COMPLETIONS_DIR)/_git-wt

lint:
	shellcheck bin/git-wt
	shellcheck install.sh

test:
	@echo "Running smoke test..."
	@cd /tmp && git init git-wt-test-repo && cd git-wt-test-repo && \
		git commit --allow-empty -m "init" && \
		$(BINDIR)/git-wt new smoke-test && \
		$(BINDIR)/git-wt list && \
		$(BINDIR)/git-wt path smoke-test && \
		$(BINDIR)/git-wt rm smoke-test && \
		cd / && rm -rf /tmp/git-wt-test-repo
	@echo "Smoke test passed!"
