FROM gcr.io/distroless/static:latest

LABEL org.opencontainers.image.title=NXTP
LABEL org.opencontainers.image.description="An NXTP client and server"
LABEL org.opencontainers.image.vendor="Keith Gaughan"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.url=https://github.com/kgaughan/nxtp
LABEL org.opencontainers.image.source=https://github.com/kgaughan/nxtp
LABEL org.opencontainers.image.documentation=https://kgaughan.github.io/nxtp/

COPY nxtp .
USER nobody
EXPOSE 12300
ENTRYPOINT ["/nxtp"]
CMD ["-endpoint", "0.0.0.0:12300"]
