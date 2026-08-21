# Using AKS dynamically crated Pod to run DB Backups and Restores

## Overview
This pod definition allows for use of an AKS pod to handle specific database related operations that are proving unreliable via Github runners, namely backup (and restore) of large databases. This should work around what are likely network \ connectivity issues between Github runners and the target resources by keeping all actions within the Azure data plane.

There are various assumptions and limitations implicit from the design of these operations:
Single instance of the pod per namespace - with the expectation this pod will typically be used for DB backup or restore operations a single instance is assumed and checked for before standard operations.

Limited access from the pod - by default a limited life SAS token is passed to the pod granting access only to the database backup container.

Limited tooling - Only AzCopy and Postgres client tools are installed, no Az CLI.

For standard backup \ restore operations the pod is run interactively which will feed back operations and errors to the user or Github runner/

## Operation

#### Standard Environment Backup

For Test or Production Cluster:
`make <Environment> aks_db_job_backup`

For development cluster:
`make <Environment> aks_db_job_backup PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

#### Standard Environment Restore (to primary database)

For Test or Production Cluster:
`make <Environment> aks_db_job_restore`

For development cluster:
`make <Environment> aks_db_job_restore PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

#### Standard Environment Restore (to primary database)

For Test or Production Cluster:
`make <Environment> aks_db_job_restore` RESTORE_FILE=<Filename, eg postgres-backup-2026-08-11_094602.sql>

For development cluster:
`make <Environment> aks_db_job_restore PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> ` RESTORE_FILE=<Filename, eg postgres-backup-2026-08-11_094602.sql>

#### Interactive Use of Pod

##### Connecting to an existing pod (eg when there has been an error in a backup \ restore job)

For Test or Production Cluster:
`make <Environment> aks_db_job_interactive_join`

For development cluster:
`make <Environment> aks_db_job_interactive_join PR_NUMBER=<PR Number> CLUSTER=<Cluster Name, eg cluster4> `

##### Creating a new pod

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

### Non-Standard Operation

Currently non-standard operations such a backing up a PTR will need to be run via an interactive pod.

Adding VERBOSE=1 to the command will show select variables values that may be of interest in troubleshooting sa well as echo the commands from the makefile.
