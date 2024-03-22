# Apply APIs

The Apply service has four different APIs, each of which cater for different audiences and use cases.

1. [Candidate API](#candidate-api)
2. [Data API](#data-api)
3. [Register API](#register-api)
4. [Vendor API](#vendor-api)

## Candidate API

📖 [Candidate API docs](https://www.apply-for-teacher-training.service.gov.uk/candidate-api)
<br>
🔐 Authenticate with [ServiceAPIUser](/app/models/service_api_user.rb)

The Candidate API provides candidate information to other services. It's currently only used by the CRM team in Get Into Teaching (GIT).

## Data API

📖 [Data API docs](https://www.apply-for-teacher-training.service.gov.uk/data-api)
<br>
🔐 Authenticate with [ServiceAPIUser](/app/models/service_api_user.rb)

The Data API provides data extracts and reporting about the Apply service. Responses are in CSV format. It's used by the Teacher Analysis Division (TAD) team.

## Register API

📖 [Register API docs](https://www.apply-for-teacher-training.service.gov.uk/register-api)
<br>
🥸 Also known as the [Recruits API](https://github.com/DFE-Digital/register-trainee-teachers/pull/3618)
<br>
🔐 Authenticate with [ServiceAPIUser](/app/models/service_api_user.rb)

The Register API provides the details of successful applications. It's currently only used by the Register service.

At the point an application is retrieved by Register, Register becomes the "source of truth" for that candidate.

## Vendor API

📖 [Vendor API docs](https://www.apply-for-teacher-training.service.gov.uk/api-docs)
<br>
🔐 Authenticate with [VendorAPIToken](/app/models/vendor_api_token.rb)

The Vendor API allows providers to manage applications programmatically: fetch applications, make offers, reject applications, etc. It makes the key functionality of Manage available via API to vendor Student Record Systems (SRS).

Users of this API authenticate with a Vendor API token. These can be issued and revoked in the support console under [Providers > API tokens](https://www.apply-for-teacher-training.service.gov.uk/support/tokens).
