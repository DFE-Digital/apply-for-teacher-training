# Workload Identity Federation

In the beginning when our applications needed to make authenticated requests to Google BigQuery we used JSON User Credentials which were stored in ENV vars.


DfE have moved away from JSON credentials and instead we use [Azure Workload Identity Federation (WIF)](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation) in order to harden security.

## How it works

We use a terraform variable [`enable_gcp_wif`](eafaea225f4e378a24984046c527d1f620d2ca1e) to set up specific pods with some keys.


This automatically sets two environment variables on the targetted pods which are used in the WIF process.

    ENV['AZURE_CLIENT_ID']
    ENV['AZURE_FEDERATED_TOKEN_FILE']

We also have a [Google Cloud Application Default Credentials (GCP credentials)](https://cloud.google.com/docs/authentication/application-default-credentials) file which is stored as an environment variable on the pods. `ENV['GOOGLE_CLOUD_CREDENTIALS_STATS']`.


### Steps

1. Get an Azure Access Token
    - Use `AZURE_CLIENT_ID` and `AZURE_FEDERATED_TOKEN_FILE` to get an access token from the URL specified in the Google Cloud Credentials.
2. Exchange the Azure Access Token for a GCP token
    - Use the Azure Access Token to get a GCP token from [Google Security Token Service API (STS)](https://cloud.google.com/iam/docs/reference/sts/rest).
3. Use the GCP token to get a Service Account Impersonation token (SAI token).
4. Use the SAI token to make authenticated requests to BigQuery.


The SAI token will expire in ~60 minutes. If the token is expired, a new token is requested.

![WIF process](https://private-user-images.githubusercontent.com/7459016/325268216-5caeaf01-9bbb-4132-80d5-1d8acbfb2a4c.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjM1MzgwNjAsIm5iZiI6MTcyMzUzNzc2MCwicGF0aCI6Ii83NDU5MDE2LzMyNTI2ODIxNi01Y2FlYWYwMS05YmJiLTQxMzItODBkNS0xZDhhY2JmYjJhNGMucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDgxMyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDA4MTNUMDgyOTIwWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9MDdlMzQ2ZmQ3ODQxNDgyODQ0OTI3NmIwMTNmNGI3OWVlMWUzYWJlYjRhOTI5YTczY2UwYWIzOWQ2MDNhYjJmZCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.rpJ_ptgHH8U_kVSbk9muby3OGlnbJeXsge6I1TvfNq8)



## Google libraries

`Google::Cloud::Bigquery` vs `Google::Apis::BigqueryV2`

Previously, when using the Service Account JSON Credentials we were able to use the `Google::Cloud::BigQuery` library. This is a higher level "modern" libarary which manages smaller details of interacting with the service. This library does not support the OAuth authentication methods we now depend on and so we need to change the BigQuery client to use the Ruby Google API client for BigQuery V2 `Google::Apis::BigqueryV2`.



### Code


| Description | Module/Path                            |
| ---         | ---                                    |
| Module      | `./../../lib/azure.rb`                 |
| Initializer | `./../../config/initializers/azure.rb` |
| Classes     | `Azure::AccessToken`                   |
|             | `Azure::GoogleTokenExchange`           |
|             | `Azure::GoogleAccessToken`             |
|             | `Azure::UserCredentials`               |


## Documentation

### Libraries
 - [RubyBigQuery#query_job](https://github.com/googleapis/google-api-ruby-client/blob/main/generated/google-apis-bigquery_v2/lib/google/apis/bigquery_v2/service.rb#L642)


 - [BigQueryV2 REST API jobs.query_job](https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query)


 - [Ruby Google::Auth::UserRefreshCredentials](https://googleapis.dev/ruby/googleauth/latest/Google/Auth/UserRefreshCredentials.html)

### WIF

 - [Configure Workload Identity Federation with AWS or Azure](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds)
 - [What are managed identities for Azure resources?](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
 - [How Application Default Credentials works](https://cloud.google.com/docs/authentication/application-default-credentials)
 - [Security Token Service API](https://cloud.google.com/iam/docs/reference/sts/rest)
