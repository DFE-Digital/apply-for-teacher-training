# Working with the load test environment

There are two applications to build and deploy when updating the load test environment:

- `apply-loadtest` : This is the Apply application which is run with [loadtest specific environment variables](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/terraform/workspace_variables/loadtest.tfvars.json). This application run as close to production mode as possible and will only require updating if the application code or environment we are testing needs to change.
- `apply-jmeter` : This application runs the relevant load test plan against `apply-loadtest`. This application only needs to be built and deployed when the load test plans require updating.


## JMeter Docker application for load-testing Apply/Manage/Vendor API

We are using [`ruby-jmeter`](https://github.com/flood-io/ruby-jmeter) to simplify the creation of [JMeter](https://jmeter.apache.org/) test plans and a custom [Dockerfile](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/jmeter/Dockerfile) to satisfy all JMeter dependencies.

We run the tests within the gov.uk PaaS and collect JMeter metrics with Prometheus, so that we can examine our load tests in [Grafana](https://grafana-bat.london.cloudapps.digital).


## Load testing with the JMeter app locally

It's worth running the load tests locally first to get an idea of how the environment behaves.

You'll need docker installed.


#### 1. Build the `apply-jmeter-runner` Docker image

```
cd jmeter
make build
```


**NOTE:** The default is to build the `latest` tagged image: `ghcr.io/dfe-digital/apply-jmeter-runner:latest`.

[You can customise the tag to build in the Makefile](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/jmeter/Makefile#L1) if necessary.

Tags can be found in [the registry](https://github.com/orgs/DFE-Digital/packages/container/package/apply-jmeter-runner).


#### 2. Start your local Apply application

In another terminal, start your local Apply application:

```
bundle exec rails s
```


#### 3. Run the test plan

Run the following Docker commands from the `jmeter/` directory.

The docker commands are different whether you are on Mac or Linux. Windows with WSL is the same as Linux. On Mac, docker runs in a VM and is not directly accessible by the host.


Linux:
```
docker run --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=test -e JMETER_WAIT_FACTOR=0.5 ghcr.io/dfe-digital/apply-jmeter-runner:latest
```

Mac:
```
docker run --rm -ti -p 8080:8080 -e JMETER_TARGET_BASEURL=http://host.docker.internal:3000 -e JMETER_TARGET_PLAN=test -e JMETER_WAIT_FACTOR=0.5 ghcr.io/dfe-digital/apply-jmeter-runner:latest
```

The `docker run` command above will just run the `test.rb` plan against your local rails server.

You can access the prometheus jmeter metrics locally at http://localhost:8080

#### 4. Run a specific plan

In these examples we'll run the `manage` plan. You can select the plan to run via the `JMETER_TARGET_PLAN` argument.

The `manage` plan relies on specific provider and course records in the target application db.


To obtain this data we need to sync with the Teacher Training API.

**Please ensure your local env file points `TEACHER_TRAINING_API_BASE_URL` to the QA instance** to avoid putting load on the production TTAPI.

To seed the required load test data you can run:

```
bundle exec rake load_test:setup_app_data
```

This takes around 15 mins to complete.

Once you have the relevant local data you can run:

Linux:
```
docker run --name apply-jmeter --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=manage -e JMETER_WAIT_FACTOR=0.5 -e JMETER_THREAD_CONFIG=0,0,0,0,0,1 ghcr.io/dfe-digital/apply-jmeter-runner:latest
```

Mac:
```
docker run --name apply-jmeter --rm -ti -p 8080:8080 -e JMETER_TARGET_BASEURL=http://host.docker.internal:3000 -e JMETER_TARGET_PLAN=manage -e JMETER_WAIT_FACTOR=0.5 -e JMETER_THREAD_CONFIG=0,0,0,0,0,1 ghcr.io/dfe-digital/apply-jmeter-runner:latest
```


## Debugging loadtest plans

If loadtest plans are generating a lot of errors locally there's likely something wrong with either authentication or the scenarios themselves.

Debugging your local Apply application should help determine authentication errors but if there's an issue with steps or scenarios in the plans themselves debugging them on the local docker container can be difficult.

One option is to run JMeter locally and execute the generated plan:

1. Execute the relevant test plan with Ruby locally, this doesn't perform a load test, it compiles a JMX file which JMeter can import.
  ```
  cd jmeter
  JMETER_TARGET_BASEURL=http://localhost:3000 ruby plans/apply.rb
  ```
2. Start the JMeter UI (you need Java, JMeter and the [Prometheus plugin](https://github.com/johrstrom/jmeter-prometheus-plugin) installed in JMeter).
3. Open the JMX file resulting from step 1. (ie. `ruby-jmeter.jmx`) in JMeter.
   At this point you can delete repetitive thread groups etc to focus on the scenario you wish to debug.
   If necessary add a ResultsTree listener so you can see the plan succeed / fail. You will be able to inspect responses from the load test in the ResultsTree.
4. Run the test plan (using the 'without pause' option to bypass any wait time).


## Deploying the loadtest applications

Download and install [Terraform 1.2.3](https://releases.hashicorp.com/terraform/1.2.3) or use [tfenv](https://github.com/tfutils/tfenv).

You can then build and deploy the `apply-loadtest` and `apply-jmeter` applications with the following steps:


#### 1. Build and deploy the `apply-loadtest` application
- Raise PIM for the Azure production subscription
- Choose a docker tag from [the registry](https://github.com/DFE-Digital/apply-for-teacher-training/pkgs/container/apply-teacher-training)
- [Login to GOVUK PaaS](https://login.london.cloud.service.gov.uk/login) and save the passcode, you'll need this to deploy the app.
- Get `SpaceDeveloper` role in the `bat-prod` PaaS space
- Deploy:
    ```
    make loadtest deploy PASSCODE=XXXX IMAGE_TAG=YYYY
    ```

If you are deploying the `apply-loadtest` application for the first time against a new database you will need seed data to run the load test plans against.
There are [rake tasks](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/lib/tasks/load_test.rake) in the Apply codebase which will sync data from the QA instance of the Teacher Training API and generate users and API Tokens.

If necessary SSH onto the apply-loadtest instance:

```
cf ssh apply-loadtest
```

Then call the rake task to populate seed data:

```
bundle exec rake load_test:setup_app_data
```

**NOTE:** You may wish to emulate production-like numbers of applications and audit entries before load testing, this can be done via the rails console:

```
100.times { GenerateTestApplications.perform_async }
```

#### 2. Log in to the GitHub Container Registry

Make sure you are logged into the GitHub container registry, this is required to publish the latest image to GHCR.

[Create a Github Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) and [login to the registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic).


#### 3. Build and publish `apply-jmeter-runner` image to GHCR

Build and publish the latest docker image by running:

```
cd jmeter
make push
```

This will build the docker image `ghcr.io/dfe-digital/apply-jmeter-runner:latest` and push it to GHCR.


#### 4. Deploy the `apply-jmeter-runner` image to PaaS

Retrieve the passcode from [the PaaS portal](https://login.london.cloud.service.gov.uk/passcode).

Run the following from the `jmeter/` directory:

```
make apply deploy PASSCODE=XXXXXX
```

This will configure the `apply-jmeter` application to run the [`apply`](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/jmeter/plans/apply.rb) test plan and deploy it.

The various load test plans live in the [jmeter/plans](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/jmeter/plans/) directory.

Replace `apply` with `manage` or `vendor` as required.

**NOTE:** run custom image
Use the IMAGE_TAG argument to create a separate jmeter image and deploy it. For example:

```
make build push IMAGE_TAG=extralogging-v7
make apply deploy IMAGE_TAG=extralogging-v7 PASSCODE=XXXXXX
```
#### 5. Start the load test

The `apply-jmeter` application will be created in a stopped state, you have to manually start and stop the application for testing:

```
cf start apply-jmeter # to start the app
cf stop apply-jmeter  # to stop the app
```

#### jmeter log
jmeter logs is located in `/app/jmeter.log`. You can stream them using vi `cf ssh`. For example:

```
cf ssh apply-jmeter -c "tail -f /app/jmeter.log"
```

By default they don't contain much. You can [enable logging](https://jmeter.apache.org/usermanual/get-started.html#logging) for more and more
components by tweaking `log4j.xml`. Rebuild, push and redeploy jmeter.

#### (Optional) Destroy the `apply-jmeter` application
Run destroy from the `jmeter/` directory to delete the app once your testing is complete:

```
cd jmeter
make apply destroy PASSCODE=XXXXXX
```

You can run deploy again to recreate/update jmeter.

## Metrics
The BAT monitoring solution based on prometheus can monitor both the load test environment and the jmeter on the client-side.
They should be added to [the monitoring configuration](https://github.com/DFE-Digital/bat-infrastructure/blob/main/monitoring/workspace-variables/prod.tfvars.json):

- `bat-prod/apply-postgres-loadtest` to `postgres_services`
- `bat-prod/apply-cache-redis-loadtest` to `redis_services`
- `apply-loadtest.apps.internal`, `apply-jmeter.apps.internal`, `apply-vendor-jmeter.apps.internal`, `apply-manage-jmeter.apps.internal` to `internal_apps`

## Other docs

- [How to restore Grafana load-testing dashboards](docs/grafana.md)
- [How to generate CSV files from logstash logs](docs/csv_from_logstash.md)
