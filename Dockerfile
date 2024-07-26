FROM alpine:latest
COPY nxtp .
EXPOSE 12300
ENTRYPOINT ["/nxtp", "-endpoint", ":12300"]
