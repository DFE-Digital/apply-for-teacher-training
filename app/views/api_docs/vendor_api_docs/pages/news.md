
This page lists news and updates to the Apply for teacher training API.

For full technical documentation, see [release notes](/api-docs/release-notes).

## 29 October 2026 -- API version 2.0 release

Version 2.0 of the Apply for teacher training vendor API is now available.

The only change in version 2.0 is that pagination is required when fetching many applications.

You need to upgrade your integration to version 2.0 before we retire earlier versions of the API in April 2027.

To prepare for this change:

1. Review the [technical documentation](api-docs/v2.0/reference).
2. If your integrations do not already use pagination, implement it using the `page` and `per_page` parameters.
3. Test the changes on sandbox.
4. Update your integrations to use the version 2.0 endpoint before April 2027.

You can contact us for help at [bat.technical-enquiries@education.gov.uk](mailto:bat.technical-enquiries@education.gov.uk) at <bat.technical-enquiries@education.gov.uk>.
