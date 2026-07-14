export CGO_ENABLED := "0"

# build the binary
build:
	go build -v -tags netgo,timetzdata -trimpath -ldflags '-s -w' -o nxtp .

# update dependencies
[group('maintenance')]
update:
	go get -u ./...
	go mod tidy
	go mod verify

# format the code
[group('maintenance')]
fmt:
	go fmt ./...

# lint the code
[group('maintenance')]
lint:
	go vet ./...
	golangci-lint run ./...

# clean build artifacts
[group('maintenance')]
clean:
	find . -name \*.orig -delete
	rm -rf nxtp dist site coverage.out coverage.html

# run the tests
[group('testing')]
tests:
	go test -cover -coverprofile=coverage.out -v ./...

# generate HTML report from coverage data
[group('testing')]
coverage-html: tests
	go tool cover -html=coverage.out -o coverage.html

# run `goreleaser release` without publishing anything
[group('testing')]
test-release:
	goreleaser release --auto-snapshot --clean --skip docker --skip publish

# update Windows timezone data and regenerate zones.go
[group('maintenance')]
rebuild-zones: update-zones
	tools/generatezones.py tools/windowsZones.xml > zones.go
	go fmt zones.go

# download the latest Windows timezone data
[group('maintenance')]
update-zones:
	curl -sL https://raw.githubusercontent.com/unicode-org/cldr/main/common/supplemental/windowsZones.xml -o tools/windowsZones.xml
