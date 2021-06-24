# BigQuery

This document explains the necessary steps to configure the app to use Google BigQuery.

## What do we use BigQuery for?

We've added BigQuery as an external store for event data. At the time of writing we will be pushing a common set of request data events from Apply to BigQuery.
[The data is sent asynchronously using Sidekiq](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/workers/send_request_events_to_bigquery.rb).


## Credentials

Credentials for authenticating with BigQuery are stored in the ENV var `BIG_QUERY_API_JSON_KEY`.
The value is a string of JSON which defines the service account credentials needed for the given environment.


### Project and dataset config

BigQuery is organised by project, projects may have multiple datasets and these may have multiple tables.

The ENV vars `BIG_QUERY_PROJECT_ID` and `BIG_QUERY_DATASET` are used in Apply to store environment specific values.


### Getting a valid ENV var values for development purposes

QA uses a test dataset and it's possible to connect to this from your local environment.

To obtain the valid value:

```
$ make qa shell
```

Once in the qa rails console you can obtain the ENV var value:

```
ENV['BIG_QUERY_API_JSON_KEY']
ENV['BIG_QUERY_PROJECT_ID']
ENV['BIG_QUERY_DATASET']
```

Configure your env locally with these vars and values and you should be able to connect to BigQuery via the rails console or rails server.


### Interacting with BigQuery

Once configured it's possible to see the data sent to BigQuery using the 'google-apis-bigquery' gem. 

See [Google Cloud Github repo for documentation](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigquery).

```
bq = Google::Cloud::Bigquery.new(project: ENV.fetch('BIG_QUERY_PROJECT_ID'))
dataset = bq.dataset(ENV.fetch('BIG_QUERY_DATASET'), skip_lookup: true)
bq_table = dataset.table('events', skip_lookup: true)
bq_table.data max: 50
```

You can also insert data.

```
bq = Google::Cloud::Bigquery.new(project: ENV.fetch('BIG_QUERY_PROJECT_ID'))
dataset = bq.dataset(ENV.fetch('BIG_QUERY_DATASET'), skip_lookup: true)
bq_table = dataset.table('events', skip_lookup: true)
bq_table.insert([{environment: 'development', request_method: 'GET', request_path: '/', request_uuid: SecureRandom.uuid, namespace: 'provider_interface', timestamp: Time.zone.now.iso8601}])
```

## Further reading

- https://cloud.google.com/bigquery
- https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigquery

