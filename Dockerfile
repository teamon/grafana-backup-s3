FROM alpine:3.11
LABEL maintainer="teamon"

RUN apk update \
	&& apk add coreutils \
	&& apk add python py2-pip && pip install awscli && apk del py2-pip \
	&& apk add openssl curl bash \
	&& rm -rf /var/cache/apk/*

RUN curl -L https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron && chmod u+x /usr/local/bin/go-cron
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/local/bin/jq && chmod u+x /usr/local/bin/jq

ENV GRAFANA_URL **None**
ENV GRAFANA_TOKEN **None**
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_REGION us-west-1
ENV S3_PREFIX 'backup'
ENV S3_ENDPOINT **None**
ENV S3_S3V4 no
ENV SCHEDULE **None**
ENV ENCRYPTION_PASSWORD **None**
ENV DELETE_OLDER_THAN **None**

ADD run.sh run.sh
ADD backup.sh backup.sh
ADD grafana.sh grafana.sh

CMD ["sh", "run.sh"]
