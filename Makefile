SOURCE:=$(wildcard *.go)

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: build
build: $(SOURCE) ## Build nxtp binary
	CGO_ENABLED=0 go build -tags netgo,timetzdata -trimpath -ldflags '-s -w'

.PHONY: tests
tests: ## Run all tests with coverage
	go test -cover -v ./...

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@

.PHONY: update
update: ## Update Go modules
	go get -u ./...
	go mod tidy

go.mod: $(SOURCE)
	go mod tidy

.PHONY: fmt
fmt: ## Format Go code
	go fmt ./...

.PHONY: lint
lint: ## Lint Go code
	go vet ./...

.PHONY: rebuild-zones
rebuild-zones: update-zones zones.go ## Update Windows timezone data and regenerate zones.go

.PHONY: update-zones
update-zones: ## Download the latest Windows timezone data
	curl -sL https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/windowsZones.xml -o tools/windowsZones.xml
