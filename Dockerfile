FROM golang:1.18 AS builder

ENV GOPATH /go
ENV APPPATH /repo
COPY . /repo
RUN cd /repo && CGO_ENABLED=0 go build -tags netgo -trimpath -ldflags '-s -w'

FROM alpine:latest
COPY --from=builder /repo/nxtp /nxtp
EXPOSE 12300
ENTRYPOINT ["/nxtp", "-endpoint", ":12300"]
