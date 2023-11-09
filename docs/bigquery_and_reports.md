## BigQuery and reports

This documents explain briefly the relationship between BigQuery and our
reports.

## BigQuery credentials

Ask Data insights team for access and credentials to access the BigQuery in
Apply.

## ITT monthly report

We generate the ITT monthly report by making queries to big query and
then generate a JSON compiling the big query responses into a single structure.

In order to see the JSON that is generated from BigQuery:

```ruby
  Publications::ITTMonthlyReportGenerator.new.to_h
```

In case any day the report fails for generate (e.g BigQuery is timing out, etc)
you can generate the JSON again by passing a generation and publication date.
The code will calculate the last sunday from the generation date and consider
that the cycle week that this data will consider in the report:

```ruby
  Publications::ITTMonthlyReportGenerator.new(
    generation_date: 1.day.ago,
    publication_date: 6.days.from_now,
  ).to_h
```

In order to know all the queries we make to big query for this report,
you can run the command in rails console:

```ruby
  Publications::ITTMonthlyReportGenerator.new.explain
```
