.PHONY: help setup validate lint release install-local

MARKETPLACE_JSON := .claude-plugin/marketplace.json
MON_PLUGIN_JSON := plugins/mon/.claude-plugin/plugin.json
AMI_PLUGIN_JSON := plugins/ami/.claude-plugin/plugin.json
PLUGIN_CACHE := $(HOME)/.claude/plugins/cache/mon-ami

help: ## Show all available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install development dependencies (jq, markdownlint-cli)
	@command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is not installed."; echo "  macOS: brew install jq"; echo "  Linux: sudo apt-get install jq"; exit 1; }
	@echo "jq: OK"
	@command -v markdownlint >/dev/null 2>&1 || { echo "markdownlint not found, installing..."; npm install -g markdownlint-cli; }
	@echo "markdownlint: OK"
	@echo ""
	@echo "Setup complete. Available tools:"
	@echo "  jq             $$(jq --version)"
	@echo "  markdownlint   $$(markdownlint --version)"

validate: ## Validate JSON manifests and version consistency
	@echo "Validating JSON..."
	@jq . $(MARKETPLACE_JSON) > /dev/null || { echo "ERROR: $(MARKETPLACE_JSON) is not valid JSON"; exit 1; }
	@jq . $(MON_PLUGIN_JSON) > /dev/null || { echo "ERROR: $(MON_PLUGIN_JSON) is not valid JSON"; exit 1; }
	@jq . $(AMI_PLUGIN_JSON) > /dev/null || { echo "ERROR: $(AMI_PLUGIN_JSON) is not valid JSON"; exit 1; }
	@echo "  $(MARKETPLACE_JSON): valid"
	@echo "  $(MON_PLUGIN_JSON): valid"
	@echo "  $(AMI_PLUGIN_JSON): valid"
	@echo ""
	@echo "Checking version consistency..."
	@MARKET_META=$$(jq -r '.metadata.version' $(MARKETPLACE_JSON)); \
	 MARKET_MON=$$(jq -r '.plugins[] | select(.name == "mon") | .version' $(MARKETPLACE_JSON)); \
	 MARKET_AMI=$$(jq -r '.plugins[] | select(.name == "ami") | .version' $(MARKETPLACE_JSON)); \
	 MON=$$(jq -r '.version' $(MON_PLUGIN_JSON)); \
	 AMI=$$(jq -r '.version' $(AMI_PLUGIN_JSON)); \
	 OK=true; \
	 if [ "$$MARKET_MON" != "$$MON" ]; then \
	   echo "ERROR: mon version mismatch!"; \
	   echo "  marketplace.json plugins[mon].version:  $$MARKET_MON"; \
	   echo "  mon/plugin.json version:                $$MON"; \
	   OK=false; \
	 fi; \
	 if [ "$$MARKET_AMI" != "$$AMI" ]; then \
	   echo "ERROR: ami version mismatch!"; \
	   echo "  marketplace.json plugins[ami].version:  $$MARKET_AMI"; \
	   echo "  ami/plugin.json version:                $$AMI"; \
	   OK=false; \
	 fi; \
	 if [ "$$OK" = false ]; then exit 1; fi; \
	 echo "  marketplace metadata: $$MARKET_META"; \
	 echo "  mon: $$MON"; \
	 echo "  ami: $$AMI"; \
	 echo ""; \
	 echo "All validations passed."

lint: ## Run markdownlint on commands/ and skills/ directories
	@MD_FILES=$$(find plugins -name '*.md' 2>/dev/null | grep -v '.gitkeep' | grep -v 'README.md'); \
	 if [ -z "$$MD_FILES" ]; then \
	   echo "No markdown files to lint."; \
	 else \
	   command -v markdownlint >/dev/null 2>&1 || { echo "markdownlint not found. Run 'make setup' first."; exit 1; }; \
	   echo "Linting markdown files..."; \
	   echo "$$MD_FILES" | xargs markdownlint; \
	 fi

release: validate ## Bump version for a plugin (interactive)
	@echo "Which plugin to release?"; \
	 echo "  1) mon  (current: $$(jq -r '.version' $(MON_PLUGIN_JSON)))"; \
	 echo "  2) ami  (current: $$(jq -r '.version' $(AMI_PLUGIN_JSON)))"; \
	 echo "  3) both"; \
	 echo ""; \
	 read -p "Choice (1/2/3): " CHOICE; \
	 case "$$CHOICE" in \
	   1) PLUGINS="mon";; \
	   2) PLUGINS="ami";; \
	   3) PLUGINS="mon ami";; \
	   *) echo "ERROR: Invalid choice."; exit 1;; \
	 esac; \
	 read -p "Bump type (patch/minor/major): " BUMP_TYPE; \
	 case "$$BUMP_TYPE" in \
	   patch|minor|major) ;; \
	   *) echo "ERROR: Invalid bump type '$$BUMP_TYPE'. Use patch, minor, or major."; exit 1;; \
	 esac; \
	 echo ""; \
	 GIT_FILES="$(MARKETPLACE_JSON)"; \
	 for PLUGIN in $$PLUGINS; do \
	   if [ "$$PLUGIN" = "mon" ]; then \
	     PJSON="$(MON_PLUGIN_JSON)"; \
	   else \
	     PJSON="$(AMI_PLUGIN_JSON)"; \
	   fi; \
	   CURRENT=$$(jq -r '.version' $$PJSON); \
	   IFS='.' read -r MAJOR MINOR PATCH <<< "$$CURRENT"; \
	   case "$$BUMP_TYPE" in \
	     patch) PATCH=$$((PATCH + 1));; \
	     minor) MINOR=$$((MINOR + 1)); PATCH=0;; \
	     major) MAJOR=$$((MAJOR + 1)); MINOR=0; PATCH=0;; \
	   esac; \
	   NEW_VERSION="$$MAJOR.$$MINOR.$$PATCH"; \
	   echo "$$PLUGIN: $$CURRENT -> $$NEW_VERSION"; \
	   jq --arg v "$$NEW_VERSION" '.version = $$v' $$PJSON > $$PJSON.tmp && mv $$PJSON.tmp $$PJSON; \
	   jq --arg n "$$PLUGIN" --arg v "$$NEW_VERSION" \
	     '(.plugins[] | select(.name == $$n)).version = $$v' \
	     $(MARKETPLACE_JSON) > $(MARKETPLACE_JSON).tmp && mv $(MARKETPLACE_JSON).tmp $(MARKETPLACE_JSON); \
	   GIT_FILES="$$GIT_FILES $$PJSON"; \
	 done; \
	 HIGHEST=$$(jq -r '[.plugins[].version] | sort | last' $(MARKETPLACE_JSON)); \
	 jq --arg v "$$HIGHEST" '.metadata.version = $$v' $(MARKETPLACE_JSON) > $(MARKETPLACE_JSON).tmp && mv $(MARKETPLACE_JSON).tmp $(MARKETPLACE_JSON); \
	 echo ""; \
	 echo "marketplace metadata.version -> $$HIGHEST"; \
	 echo ""; \
	 echo "Run these commands to commit the release:"; \
	 echo ""; \
	 echo "  git add $$GIT_FILES"; \
	 echo "  git commit -m \"release: mon-ami v$$HIGHEST\""; \
	 echo ""

install-local: ## Symlink plugins to Claude cache for local testing
	@for PLUGIN in mon ami; do \
	   PJSON="plugins/$$PLUGIN/.claude-plugin/plugin.json"; \
	   VERSION=$$(jq -r '.version' $$PJSON); \
	   echo "Installing $$PLUGIN v$$VERSION locally..."; \
	   mkdir -p $(PLUGIN_CACHE)/$$PLUGIN; \
	   rm -rf $(PLUGIN_CACHE)/$$PLUGIN/$$VERSION; \
	   ln -sf $(CURDIR)/plugins/$$PLUGIN $(PLUGIN_CACHE)/$$PLUGIN/$$VERSION; \
	   echo "  $(CURDIR)/plugins/$$PLUGIN -> $(PLUGIN_CACHE)/$$PLUGIN/$$VERSION"; \
	 done
	@echo ""
	@echo "If this is the first install, run these plugin commands in Claude Code:"
	@echo "  /plugin marketplace add christophercampbell/mon-ami"
	@echo "  /plugin install mon@mon-ami"
	@echo "  /plugin install ami@mon-ami"
