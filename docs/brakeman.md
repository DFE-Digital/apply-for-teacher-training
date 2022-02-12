# Security scanning with Brakeman

[Brakeman](https://github.com/presidentbeef/brakeman) is a static analysis tool which checks for security vulnerabilities.

It is run as part of our CI process and will fail if new vulnerabilities have been introduced.

To run it locally use: `bundle exec brakeman`

This looks at the [`config/brakeman.yml`](config/brakeman.yml) config file which can be used to include/skip checks and files/directories.

We are also using a `brakeman.ignore` file which lives in `/config` and is checked in to Git. This file is used to ignore false positive results.

To update the `brakeman.ignore` file run `bundle exec brakeman -I`. There are good docs for ignoring false positives [here](https://brakemanscanner.org/docs/ignoring_false_positives/).
