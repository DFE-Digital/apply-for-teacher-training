## BigQuery and reports

This documents explain briefly the relationship between BigQuery and our
reports.

We make requests to Bigquery to populate the weekly and monthly performance reports.

We have to authenticate requests to Bigquery and we must use [WIF (Workload Identity Federation)](./workload_identity_federation.md)


## Running Locally

*It is not possible to run things that contact BigQuery locally. This must be done on a review app or QA.*

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

In order to save into the database you can run the following:

```ruby
  Publications::ITTMonthlyReportGenerator.new(
    generation_date: 1.day.ago,
    publication_date: 6.days.from_now,
  ).call
```

In order to know all the queries we make to BigQuery for this report,
you can run the command in rails console:

```ruby
  Publications::ITTMonthlyReportGenerator.new.describe
```
