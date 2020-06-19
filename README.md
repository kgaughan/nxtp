# nxtp

A small [NXTP](https://github.com/Threetwosevensixseven/nxtp) client and
server.

Currently this only accepts IANA timezone specifications. I need to add a map
to convert Windows timezone specifications to IANA ones.

## Building

Run the following:

```
CGO_ENABLED=0 go build -ldflags '-s -w'
```

That combination of flags ensures the binary is as small as possible without
crunching.

If building for a Raspberry PI, you'll need to also specify `GOARCH=arm` and
`GOARM=5`. Be sure to specify `GOOS` too, with a value such as `linux`,
`netbsd`, &c.
