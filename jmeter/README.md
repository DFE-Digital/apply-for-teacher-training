# JMeter docker app for load-testing Apply/Manage/Vendor API

We are using `ruby-jmeter` to simplify the creation of JMeter test plans and a custom Dockerfile to satisfy all JMeter dependencies, run the tests within the gov.uk PaaS and collect jmeter metrics with Prometheus, so that we can examine our load tests in Grafana.

## Build the loadtest environment
- Raise PIM for the Azure production subscription
- Choose a docker tag from [the registry](https://github.com/DFE-Digital/apply-for-teacher-training/pkgs/container/apply-teacher-training)
- Get SpaceDeveloper role in the bat-prod paas space
- Deploy
    ```
    make loadtest deploy PASSCODE=XXXX IMAGE_TAG=YYYY
    ```

## Testing the jmeter app locally

You'll need docker installed.

```
cd jmeter && docker build . -t jmeter
docker run --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=test -e JMETER_WAIT_FACTOR=0.5 jmeter
```

The `docker run` command above will just run the `test.rb` plan against your local rails server. Here is an example of something more interesting:

```
docker run --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=manage -e JMETER_WAIT_FACTOR=0.5 -e JMETER_THREAD_CONFIG=0,0,0,0,0,1 jmeter
```

Most of these calls will fail, though, because you probably don't have the required provider users in your database. You can edit `manage.rb` and carry on building your local docker images, however, to use provider user UIDs that you have.

You can check jmeter prometheus metrics are being exported by visiting http://locahost:8080 in your browser.

## Deploying the app

Make sure you are logged into the GitHub container register, this is required to publish the latest image to GHCR.

```
docker login -u github -p <GITHUB_TOKEN> ghcr.io
```

Build and publish the latest docker image by running `./build.sh` from your local terminal. This will build the docker image `[ghcr.io/dfe-digital/apply-jmeter-runner:latest]` and push it to GHCR.

<br/><br/>

Download and install [Terraform 0.14.9](https://releases.hashicorp.com/terraform/0.14.9) or use [tfenv](https://github.com/tfutils/tfenv).

Then run the below make command from inside the `/jmeter` folder. Retrieve the passcode from https://login.london.cloud.service.gov.uk/passcode.

```
make apply deploy PASSCODE=XXXXXX
```

This will deploy jmeter to run the "apply" test. Replace "apply" with "manage", "vendor" or "find" as needed.

The app will be created in a stopped state, you have to manually start and stop the app for testing.

```
cf start apply-jmeter # to start the app
cf stop apply-jmeter  # to stop the app
```

Run destroy to delete the app once your testing is complete:

```
make apply destroy PASSCODE=XXXXXX
```

You can run deploy again to recreate/update jmeter.

## Other docs

- [How to restore Grafana load-testing dashboards](docs/grafana.md)
- [How to generate CSV files from logstash logs](docs/csv_from_logstash.md)
