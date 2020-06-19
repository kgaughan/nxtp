# nxtp

A small [NXTP](https://github.com/Threetwosevensixseven/nxtp) client and
server.

## Usage

To run the server, simply do:

```console
$ nxtp
```

By default, the server runs on _localhost:12300_, but you can get it to listen
on a different interface with the `-endpoint` flag:

```console
$ nxtp -endpoint :12300
```

To use it as a client, pass the `-client` flag. The `-endpoint` flag can be
used with this to specify the server to connect to:

```console
$ nxtp -client -endpoint time.nxtel.org
```

By default, the client assumes the timezone to use is UTC. However, you can
supply a Windows timezone specifier with the `-tz` flag:

```console
$ nxtp -client -endpoint time.nxtel.org:12300 -tz "Nepal Standard Time"
```

In server mode, `nxtp` supports IANA timezone specifiers, but other servers are
not guaranteed to support anything other than Windows timezone specifiers.

## Building

Run the following:

```console
$ CGO_ENABLED=0 go build -ldflags '-s -w'
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
