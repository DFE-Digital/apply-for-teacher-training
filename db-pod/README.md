# Using AKS dynamically crated Pod to run DB Backups and Restores

## Overview
This pod definition allows for use of an AKS pod to handle specific database related operations that are proving unreliable via Github runners, namely backup (and restore) of large databases. This should work around what are likely network \ connectivity issues between Github runners and the target resources by keeping all actions within the Azure data plane.

There are various assumptions and limitations implicit from the design of these operations:
Single instance of the pod per namespace - with the expectation this pod will typically be used for DB backup or restore operations a single instance is assumed and checked for before standard operations.

Limited access from the pod - by default a limited life SAS token is passed to the pod granting access only to the database backup container.

Limited tooling - Only AzCopy and Postgres client tools are installed, no Az CLI.

For standard backup \ restore operations the pod is run interactively which will feed back operations and errors to the user or Github runner/

## Operation

### Standard Environment Backup

For Test or Production Cluster:
`make <Environment> aks_db_job_backup`

For development cluster:
`make <Environment> aks_db_job_backup PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

### Standard Environment Restore (to primary database)

For Test or Production Cluster:
`make <Environment> aks_db_job_restore` RESTORE_FILE=<Filename, eg postgres-backup-2026-08-11_094602.sql>

For development cluster:
`make <Environment> aks_db_job_restore PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> ` RESTORE_FILE=<Filename, eg postgres-backup-2026-08-11_094602.sql>

### Interactive Use of Pod

#### Connecting to an existing pod (eg when there has been an error in a backup \ restore job)

For Test or Production Cluster:
`make <Environment> aks_db_job_interactive_join`

For development cluster:
`make <Environment> aks_db_job_interactive_join PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

#### Creating a new pod

For Test or Production Cluster:
`make <Environment> aks_db_job_interactive_new`

For development cluster:
`make <Environment> aks_db_job_interactive_new PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

#### Killing (backup \ restore related) Pods

A choice has been made to limit the pod to a single instance per namespace to prevent duplicate actions. The pod created to handle the backup should be killed after completion but if it errors it is likely to not complete this step. In this case it should manually be killed off (or used for investigation and then killed). If a pod is manually created it will not be automatically killed, this will need to be done manually.

For Test or Production Cluster:
`make <Environment> aks_db_job_backup`

For development cluster:
`make <Environment> aks_db_job_backup PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

## Non-Standard Operation

Currently non-standard operations such a backing up a PTR will need to be run via an interactive pod.

### Backups of non-standard Servers (eg PTRs)

1. Get the current DATABASE_URL while connected to a pod `echo $DATABASE_URL`
2. Change the server name to the PTR version and export it back out for use in later commands...
`export DATABASE_URL="postgres://postgres:<existing password>@<ptr name>.postgres.database.azure.com:5432/<database>?sslmode=require"`
3. Run pg_dump, either use the same command as in the backup script or customise it to suit the use case eg

```
pg_dump \
  -d "$DATABASE_URL" \
  -E utf8 \
  --clean \
  --compress=1 \
  --if-exists \
  --no-owner \
  --verbose \
  --no-password \
  -f pg_backup.gz \
  2>&1 | tee pg_dump.log
```

4. Obtain a SAS URL with create permission for the target storage account, EXPORT SAS_TOKEN=="<token>" (the default for an interactive session is read only).

5. Join with the blob url and backup file name (pick a new name based on data time, postgres-backup-2026-08-24_082726.sql), `https://<storage account>.blob.core.windows.net/<container name>/<backup filename>?<SAS Token>, export to a environment variable, eg export `AZURE_STORAGE_SAS_URL=<URL+SAS>`

5. Use AzCopy to copy the backup file to the storage account
```
    azcopy cp ./pg_backup.gz "$AZURE_STORAGE_SAS_URL"
```

## Troubleshooting

Adding VERBOSE=1 to the command will show select variables values that may be of interest in troubleshooting as well as echo the commands from the makefile. eg `make <Environment> aks_db_job_interactive_join VERBOSE=1`

### CRLF Issues running on Windows WSL
Typical errors will be something like:
```
: invalid option nameup-secret.sh: line 2: set: pipefail
make: *** [Makefile:482: aks_db_job_prepare_interactive] Error 2
```
By default git converts line endings based on the OS and direction (eg on checkout to Windows, CRLF are used which are converted to LF on push to remote). This is generally good but does mean bash (or other) scripts running on WSL will likely fail with errors along the lines of the above.
As we typically want the standard git behaviour the best option seems to be to explicitly change the line endings for script files as required.
Test with `file scripts/<filename.sh>` if you see `shell script, ASCII text executable, with CRLF line terminators` then you'll need to convert it.

This command will handle a single file.
```
sed -i 's/\r$//' scripts/<filename.sh>
```

This modifies files that actually contain CRLF line endings, avoiding unnecessary file changes.
```
find ./scripts -name "*.sh" -exec grep -Il $'\r' {} + | xargs sed -i 's/\r$//'
```
