nxtp: main.go zones.go
	CGO_ENABLED=0 go build -tags netgo -trimpath -ldflags '-s -w'

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@

rebuild-zones: update-zones zones.go

update-zones:
	curl -sL https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/windowsZones.xml -o tools/windowsZones.xml

.PHONY: rebuild-zones update-zones
