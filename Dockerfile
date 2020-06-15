FROM alpine:3.12

RUN apk add --no-cache curl openssl xxd jq
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
