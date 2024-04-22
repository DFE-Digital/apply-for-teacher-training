# Review apps

When a new PR is opened, you have the option to deploy a review app into the `bat-qa` namespace. A deployment is initiated by adding the `deploy` label either when the PR is created or retrospectively. The app is destroyed when the PR is closed.

Review apps have `HOSTING_ENVIRONMENT` set to `review`, an empty database which gets seeded with local dev data, and a URL which will be `https://apply-review-{PR_NUMBER}.test.teacherservices.cloud/candidate/account/`.

Management of review apps follow the same processes as our standard AKS based apps.
