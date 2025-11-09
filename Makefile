NAME:=nxtp

SOURCE:=$(wildcard *.go)

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: build
build: go.mod $(NAME) ## Build the nxtp binary

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf $(NAME) dist coverage.out coverage.html

$(NAME): $(SOURCE)
	CGO_ENABLED=0 go build -v -tags netgo,timetzdata -trimpath -ldflags '-s -w' -o $@ .

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@

.PHONY: fmt
fmt: ## Format the code
	go fmt ./...

.PHONY: lint
lint: ## Lint the code
	go vet ./...
	golangci-lint run ./...

.PHONY: tests
tests: ## Run the tests
	go test -cover -coverprofile=coverage.out -v ./...

coverage.out: tests

.PHONY: coverage-html
coverage-html: coverage.out ## Generate HTML report from coverage data
	go tool cover -html=coverage.out -o coverage.html

.PHONY: test-release
test-release: ## Run `goreleaser release` without publishing anything
	goreleaser release --auto-snapshot --clean --skip publish

.PHONY: rebuild-zones
rebuild-zones: update-zones zones.go ## Update Windows timezone data and regenerate zones.go

.PHONY: update-zones
update-zones: ## Download the latest Windows timezone data
	curl -sL https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/windowsZones.xml -o tools/windowsZones.xml
