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
$ nxtp -client -endpoint time.nxtel.org:12300
```

By default, the client assumes the timezone to use is UTC. However, you can
supply a Windows timezone specifier with the `-tz` flag:

```console
$ nxtp -client -endpoint time.nxtel.org:12300 -tz "Nepal Standard Time"
```

In server mode, `nxtp` supports IANA timezone specifiers, but other servers are
not guaranteed to support anything other than Windows timezone specifiers.

## Running as a daemon

`nxtp` doesn't daemonise due to complications from the Go runtime, so it's up
to your process supervisor to manage it.  With systemd, you can use the
following unit:

```ini
[Unit]
Description = Network neXt Time Protocol (NXTP) server
After = network.target

[Service]
Type = simple
ExecStart = /usr/bin/nxtp
KillMode = process
RestartSec = 5s
Restart = on-failure
```

Under `contrib` is a NetBSD rc script. It expects _daemond_ to be installed
to help daemonise the server, which you can do with `pkgin install daemond`.

## Running under Docker

To start the daemon in a Docker container, run:

```sh
docker run -d -p 12300:12300 ghcr.io/kgaughan/nxtp:latest
```

## Building

Run the following:

```console
$ make
```

If building for a Raspberry PI, you'll need to also define `GOARCH=arm` in your
environment, `GOOS` too, with a value of the target OS such as `linux`,
`netbsd`, &c.

## Timezone data

Translations of Windows timezone specifications to IANA ones are souced from
the [Unicode Common Locale Data Repository](https://github.com/unicode-org/cldr),
specifically `common/supplemental/windowsZones.xml` in that repository.
