FROM alpine:3.11

LABEL org.label-schema.name="duplicacy-autobackup" \
    org.label-schema.description="Painless automated backups to multiple storage providers with Docker and duplicacy." \
    org.label-schema.url="http://andradaprieto.es" \
    org.label-schema.vcs-ref="2.5.0" \
    org.label-schema.vcs-url="https://github.com/jandradap/duplicacy-autobackup" \
    org.label-schema.vendor="Jorge Andrada Prieto" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    maintainer="Jorge Andrada Prieto <jandradap@gmail.com>"

ENV BACKUP_SCHEDULE='* * * * *' \
    BACKUP_NAME='' \
    BACKUP_LOCATION='' \
    BACKUP_ENCRYPTION_KEY='' \
    BACKUP_IMMEDIATLY='no' \
    BACKUP_IMMEDIATELY='no' \
    DUPLICACY_BACKUP_OPTIONS='-threads 4 -stats' \
    DUPLICACY_INIT_OPTIONS='' \
    AWS_ACCESS_KEY_ID='' \
    AWS_SECRET_KEY='' \
    WASABI_KEY='' \
    WASABI_SECRET='' \
    B2_ID='' \
    B2_KEY='' \
    HUBIC_TOKEN_FILE='' \
    SSH_PASSWORD='' \
    SSH_KEY_FILE='' \
    DROPBOX_TOKEN='' \
    AZURE_KEY='' \
    GCD_TOKEN='' \
    GCS_TOKEN_FILE='' \
    ONEDRIVE_TOKEN_FILE='' \
    PRUNE_SCHEDULE='0 0 * * *' \
    DUPLICACY_PRUNE_OPTIONS=''

RUN apk --update --clean-protected --no-cache add \
  ca-certificates \
  openssh \
  && rm -rf /var/cache/apk/* \
  && update-ca-certificates \
  && mkdir /app

WORKDIR /app

COPY ./assets/* ./

RUN chmod +x *.sh

RUN export DUPLICACY_VERSION=$(cat /app/VERSION) \
    ARCH="$(uname -m)";\
    if [ "$ARCH" == "x86_64" ]; then \
        DUPLICACY_ARCH="x64"; \
    elif [ "$ARCH" == "aarch64" ]; then \
        DUPLICACY_ARCH="arm64"; \
    elif [ "$ARCH" == "armv7l" ]; then \
        DUPLICACY_ARCH="arm"; \
    fi; \
    wget https://github.com/gilbertchen/duplicacy/releases/download/v${DUPLICACY_VERSION}/duplicacy_linux_${DUPLICACY_ARCH}_${DUPLICACY_VERSION} -O /usr/bin/duplicacy && \
    chmod +x /usr/bin/duplicacy

VOLUME ["/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
