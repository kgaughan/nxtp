SOURCE:=$(wildcard *.go)

nxtp: $(SOURCE)
	CGO_ENABLED=0 go build -tags netgo,timetzdata -trimpath -ldflags '-s -w'

.PHONY: tests
tests:
	go test -cover -v ./...

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@

.PHONY: update
update:
	go get -u ./...
	go mod tidy

go.mod: $(SOURCE)
	go mod tidy

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: lint
lint:
	go vet ./...

.PHONY: rebuild-zones
rebuild-zones: update-zones zones.go

.PHONY: update-zones
update-zones:
	curl -sL https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/windowsZones.xml -o tools/windowsZones.xml
