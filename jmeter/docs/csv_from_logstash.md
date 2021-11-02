# How to generate CSV files from logstash logs

### Copy-pasting from Logit.io

Saved search (KQL): `hosting_environment:production AND service:web AND application:apply-prod`
with filter: `provider_user_admin_url exists`

Logit allows you to export a JSON of results, via Copy-Paste, limited to 500 records.

This corresponds to nearly a day's worth of Manage page loads (614).

I was able to convert this JSON result set into a CSV with `jq`.

```bash
jq -r '.hits.hits[]._source | .time, .payload["method"], .payload["path"], .payload["provider_user_admin_url"]' manage-1.json | xargs -n4 -d'\n' | sed -e 's/ /,/g' > manage-1.csv
```

To find the unique users in this dataset (44 unique users today):

```bash
jq -r '.hits.hits[]._source | .payload["provider_user_admin_url"]' manage-1.json | sort | uniq > manage-1.users.txt
```

Using the same approach for API calls (about 40/day):

```bash
jq -r '.hits.hits[]._source | .time, .payload["method"], .payload["path"], .payload["since"], .payload["vendor_api_token_id"]' api-1.json | xargs -n5 -d'\n' | sed -e 's/ /,/g' > api-1.csv
```

and (10 unique api keys)

```bash
jq -r '.hits.hits[]._source | .payload["vendor_api_token_id"]' api-1.json | sort | uniq > api-1.keys.csv
```

This approach also works with more data, if you can export all Apply logs for a period.

