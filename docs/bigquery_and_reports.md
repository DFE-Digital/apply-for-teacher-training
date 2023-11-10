## BigQuery and reports

This documents explain briefly the relationship between BigQuery and our
reports.

## BigQuery credentials

Ask [#twd_data_insights](https://app.slack.com/client/T50RK42V7/C01H0LBCBDW) on Slack
for access and credentials to access the BigQuery in Apply.

The moment you have the credentials, locally you can add this env vars to `.env`:

1. ENV['BIG_QUERY_PROJECT_ID']
2. ENV['DFE_BIGQUERY_API_JSON_KEY']

## ITT monthly report

We generate the ITT monthly report by making queries to BigQuery and
then generate a JSON compiling the BigQuery responses into a single structure.

In order to see the JSON that is generated from BigQuery:

```ruby
  Publications::ITTMonthlyReportGenerator.new.to_h
```

In case any day the report fails to generate (e.g BigQuery is timing out, etc)
you can generate the JSON again by passing a generation and publication date.
The code will calculate the last Sunday from the generation date and consider
that the cycle week that this data will consider in the report:

```ruby
  Publications::ITTMonthlyReportGenerator.new(
    generation_date: 1.day.ago,
    publication_date: 6.days.from_now,
  ).to_h
```

In order to know all the queries we make to BigQuery for this report,
you can run the command in rails console:

```ruby
  Publications::ITTMonthlyReportGenerator.new.describe
```
