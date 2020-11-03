# Brakeman

[Brakeman](https://github.com/presidentbeef/brakeman) is a static analysis tool which checks for security vulnerabilities.

It is run as part of our CI process and will fail if new vulnerabilities have been introduced.

To run it locally use: `brakeman -c brakeman.yml`

This looks at the `brakeman.yml` config file which can be used to include/skip checks and files/directories.

We are also using a `brakeman.ignore` file which lives in `/config` and is checked in to Git. This file is used to ignore false positive results.

To update the `brakeman.ignore` file run `brakeman -c brakeman.yml -I`. There are good docs for ignoring false positives [here](https://brakemanscanner.org/docs/ignoring_false_positives/).
