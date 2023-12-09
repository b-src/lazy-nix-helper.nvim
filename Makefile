##@ Main Targets

.PHONY: all
all: ## Remove test dependencies and run automated tests
all: clean test

.PHONY: clean
clean: ## Remove test dependencies
clean:
	@rm -rf test_dependencies/

##@ Test Targets

# TODO: look at adding --noplugin when setup handles installing its own deps
.PHONY: test
test: ## Run automated tests
test:
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory tests { minimal_init = 'tests/init.lua' }"

##@ Help Targets

.PHONY: help
help: ## Print this help text
help:
	@awk 'BEGIN { \
		FS = ":.*##"; \
		printf "Usage: make \033[36m<target>\033[0m\n" \
	} \
	/^[a-zA-Z_-]+:.*?##/ { \
		printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 \
	} \
	/^##@/ { \
	printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	} \
	' $(MAKEFILE_LIST)
