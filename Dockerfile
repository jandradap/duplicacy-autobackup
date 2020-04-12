FROM alpine:3.7

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
			org.label-schema.name="ocp-utils" \
			org.label-schema.description="Generates table of contents for markdown files inside local git repository." \
			org.label-schema.url="http://andradaprieto.es" \
			org.label-schema.vcs-ref=$VCS_REF \
			org.label-schema.vcs-url="https://github.com/jandradap/ocp-utils" \
			org.label-schema.vendor="Jorge Andrada Prieto" \
			org.label-schema.version=$VERSION \
			org.label-schema.schema-version="1.0" \
			maintainer="Jorge Andrada Prieto <jandradap@gmail.com>"

ARG DUPLICACY_VERSION=2.5.0

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
  && rm -rf /var/cache/apk/* \
  && update-ca-certificates
  
RUN wget https://github.com/gilbertchen/duplicacy/releases/download/v${DUPLICACY_VERSION}/duplicacy_linux_x64_${DUPLICACY_VERSION} \
  -O /usr/bin/duplicacy && \
  chmod +x /usr/bin/duplicacy

RUN mkdir /app

WORKDIR /app

ADD assets/*.sh ./

RUN chmod +x *.sh

VOLUME ["/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
