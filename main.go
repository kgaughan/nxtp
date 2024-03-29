package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"path"
	"strings"
	"time"
)

var (
	endpoint = flag.String("endpoint", "localhost:12300", "IP endpoint")
	client   = flag.Bool("client", false, "Run in client mode")
	tz       = flag.String("tz", "UTC", "Timezone to use in query")
	Version  = "unknown"
)

func main() {
	flag.Usage = func() {
		out := flag.CommandLine.Output()
		name := path.Base(os.Args[0])
		fmt.Fprintf(out, "%s (%s) - A small NXTP client and server.\n\n", name, Version)
		fmt.Fprintf(out, "Usage:\n\n")
		flag.PrintDefaults()
	}
	flag.Parse()
	if *client {
		runClient()
	} else {
		runServer()
	}
}

func runClient() {
	if len(*tz) > 60 {
		log.Fatalf("Timezone too long: '%v'", *tz)
	}
	conn, err := net.Dial("tcp", *endpoint)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()
	dt, tm := makeRequest(conn, *tz)
	fmt.Printf("Date: %s; Time: %s\n", dt, tm)
}

func makeRequest(conn io.ReadWriter, tz string) (string, string) {
	reqBuf := make([]byte, 3+len(tz))
	reqBuf[0] = 1
	reqBuf[1] = byte(len(tz))
	for i := 0; i < len(tz); i++ {
		reqBuf[i+2] = tz[i]
	}
	setChecksum(reqBuf, len(reqBuf))
	if err := sendBuffer(conn, reqBuf); err != nil {
		log.Fatal(err)
	}

	resBuf := make([]byte, 22)
	if _, err := recvBuffer(conn, resBuf); err != nil {
		log.Fatal(err)
	}
	if resBuf[0] != 1 || resBuf[1] != 10 || resBuf[2] != 8 || !testChecksum(resBuf, len(resBuf)) {
		log.Fatal("Bad response:", resBuf)
	}

	return string(resBuf[3:13]), string(resBuf[13:21])
}

func runServer() {
	listener, err := net.Listen("tcp", *endpoint)
	if err != nil {
		log.Fatal(err)
	}
	for {
		if conn, err := listener.Accept(); err != nil {
			log.Println(err)
		} else {
			go handleConnection(conn)
		}
	}
}

func handleConnection(conn io.ReadWriteCloser) {
	defer conn.Close()

	// Version 1 request format:
	//
	// Name      Size   Notes
	// --------  -----  -----------------------------------------------------
	// Version   1 	    Always 1
	// CodeLen   1      Length of Code in bytes. Between 0 and 60
	// Code      0..60  Timezone code in ASCII
	// Checksum  1      XOR checksum of the request
	//
	// Max size is 3 + 60 = 63
	reqBuf := make([]byte, 63)
	// This is call to .Read() is janky. It assumes that the whole request
	// will come in at once and that a malicious client won't just send slow,
	// byte-by-byte requests. I'd much prefer if I could describe the shape of
	// the incoming data and the relationship between CodeLen and Code.
	// Thankfully, the OS buffers should be significantly bigger than 63B, so
	// this isn't a practical issue, but it bugs me regardless.
	if n, err := conn.Read(reqBuf); err == nil {
		codeLen := int(reqBuf[1])
		if n < 3 || reqBuf[0] != 1 || codeLen != n-3 || !testChecksum(reqBuf, codeLen+3) {
			log.Print("Malformed request:", reqBuf)
			return
		}

		tz := string(reqBuf[2 : codeLen+2])
		location, err := queryTimezone(tz)
		if err != nil {
			// Bad timezone: ignore requests
			return
		}

		// Version 1 response format:
		//
		// Name      Size  Notes
		// --------  ----  -----
		// Version   1     Always 1
		// DateLen   1     Length of Date field; always 10
		// TimeLen   1     Length of Time field; always 8
		// Date      10    Calendar date in dd/MM/yyyy format; ASCII
		// Time      8     Time of day in HH:mm:ss format; ASCII
		// Checksum  1     XOR checksum of the response
		//
		// Max size is 4 + 10 + 8 = 22 bytes
		resBuf := make([]byte, 22)
		now := time.Now().In(location)
		payload := now.Format("02/01/200615:04:05")
		resBuf[0] = 1
		resBuf[1] = 10
		resBuf[2] = 8
		for i := 0; i < len(payload); i++ {
			resBuf[i+3] = payload[i]
		}
		setChecksum(resBuf, len(resBuf))
		if err := sendBuffer(conn, resBuf); err != nil {
			log.Print(err)
			return
		}
	}
}

func sendBuffer(conn io.Writer, buf []byte) error {
	offset := 0
	for offset < len(buf) {
		n, err := conn.Write(buf[offset:])
		if err != nil {
			return fmt.Errorf("truncated respons: %w", err)
		}
		offset += n
	}
	return nil
}

func recvBuffer(conn io.Reader, buf []byte) (int, error) {
	offset := 0
	for offset < len(buf) {
		var n int
		var err error
		if n, err = conn.Read(buf[offset:]); err != nil {
			return 0, fmt.Errorf("truncated request: %w", err)
		}
		offset += n
	}
	return offset, nil
}

func calcChecksum(buf []byte, length int) byte {
	var sum byte
	sum = 123 // seed
	for i := 0; i < length-1; i++ {
		sum ^= buf[i]
	}
	return sum
}

func testChecksum(buf []byte, length int) bool {
	return buf[length-1] == calcChecksum(buf, length)
}

func setChecksum(buf []byte, length int) {
	buf[length-1] = calcChecksum(buf, length)
}

func normalizeTimezone(tz string) string {
	normalizedTz := strings.ToLower(strings.ReplaceAll(tz, " ", ""))
	if ianaTz, ok := windowsTZs[normalizedTz]; ok {
		return ianaTz
	}
	// Fall back to treating it as an IANA timezone specification
	return tz
}

func queryTimezone(tz string) (*time.Location, error) {
	loc, err := time.LoadLocation(normalizeTimezone(tz))
	if err != nil {
		return nil, fmt.Errorf("could not query timezone %q: %w", tz, err)
	}
	return loc, nil
}
