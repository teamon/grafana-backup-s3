# grafana-backup-s3

Backup Grafana to S3 (supports periodic backups)

Heavily based on https://github.com/itbm/postgresql-backup-s3 and https://github.com/software-mansion-labs/grafana-backup-s3.

## Basic Usage

```bash
$ docker run \
  -e S3_ACCESS_KEY_ID=key \
  -e S3_SECRET_ACCESS_KEY=secret \
  -e S3_BUCKET=my-bucket \
  -e S3_PREFIX=backup \
  -e GRAFANA_URL=http://some.host.org:3000 \
  -e GRAFANA_TOKEN=token
  teamon/grafana-backup-s3
```

## Kubernetes Deployment

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-backup
spec:
  selector:
    matchLabels:
      app: grafana-backup
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: grafana-backup
    spec:
      containers:
      - name: grafana-backup
        image: teamon/grafana-backup-s3
        imagePullPolicy: Always
        env:
        - name: GRAFANA_URL
          value: ""
        - name: GRAFANA_TOKEN
          value: ""
        - name: S3_ACCESS_KEY_ID
          value: ""
        - name: S3_SECRET_ACCESS_KEY
          value: ""
        - name: S3_BUCKET
          value: ""
        - name: S3_ENDPOINT
          value: ""
        - name: S3_PREFIX
          value: ""
        - name: SCHEDULE
          value: ""
```

## Environment variables

- `GRAFANA_URL` Grafana instance URL *required*
- `GRAFANA_TOKEN` Grafana API token *required*
- `S3_ACCESS_KEY_ID` your AWS access key *required*
- `S3_SECRET_ACCESS_KEY` your AWS secret key *required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `S3_PREFIX` path prefix in your bucket (default: 'backup')
- `S3_REGION` the AWS S3 bucket region (default: us-west-1)
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required for [minio](https://minio.io) servers (default: no)
- `SCHEDULE` backup schedule time, see explainatons below
- `ENCRYPTION_PASSWORD` password to encrypt the backup. Can be decrypted using `openssl aes-256-cbc -d -in backup.sql.gz.enc -out backup.sql.gz`
- `DELETE_OLDER_THAN` delete old backups, see explanation and warning below

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

### Delete Old Backups

You can additionally set the `DELETE_OLDER_THAN` environment variable like `-e DELETE_OLDER_THAN="30 days ago"` to delete old backups.

WARNING: this will delete all files in the S3_PREFIX path, not just those created by this script.

### Encryption

You can additionally set the `ENCRYPTION_PASSWORD` environment variable like `-e ENCRYPTION_PASSWORD="superstrongpassword"` to encrypt the backup. It can be decrypted using `openssl aes-256-cbc -d -in backup.sql.gz.enc -out backup.sql.gz`.
