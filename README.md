# nxtp

A small [NXTP](https://github.com/Threetwosevensixseven/nxtp) client and
server.

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

## Timezone data

Translations of Windows timezone specifications to IANA ones are souced from
the [Unicode Common Locale Data Repository](https://github.com/unicode-org/cldr),
specifically `common/supplemental/windowsZones.xml` in that repository.

Run `generatezones.py` to convert a copy of that file to Go.
