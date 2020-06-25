nxtp: main.go zones.go
	CGO_ENABLED=0 go build -ldflags '-s -w'

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@

rebuild-zones: update-zones zones.go

update-zones:
	curl -L https://github.com/unicode-org/cldr/raw/master/common/supplemental/windowsZones.xml -o tools/windowsZones.xml

.PHONY: rebuild-zones update-zones
