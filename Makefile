nxtp: main.go zones.go
	CGO_ENABLED=0 go build -ldflags '-s -w'

zones.go: tools/windowsZones.xml
	tools/generatezones.py $^ > $@
	go fmt $@
