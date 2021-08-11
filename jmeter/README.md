# JMeter docker app for load-testing Apply/Manage/Vendor API

We are using `ruby-jmeter` to simplify the creation of JMeter test plans and a custom Dockerfile to satisfy all JMeter dependencies, run the tests within the gov.uk PaaS and collect jmeter metrics with Prometheus, so that we can examine our load tests in Grafana.

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

Download and install [Terraform 0.14.9](https://releases.hashicorp.com/terraform/0.14.9)

Create a `terraform.tfvars` file with the below content
```
cf_user         = "<paas user id>" # set to null if cf_sso_passcode is not null
cf_password     = "<password>"     # set to null if cf_sso_passcode is not null
cf_space        = "bat-qa" # or "bat-prod"
cf_sso_passcode = null # or value obtained from https://login.london.cloud.service.gov.uk/passcode
prometheus_app  = "prometheus-bat-qa" # "prometheus-bat" when space is bat-prod
```

if `cf_sso_passcode` is supplied make sure `cf_user` and `cf_password` are set to null.

Then run the below commands from inside the `/jmeter` folder.

```
terraform init # Should be required only once.
terraform apply -var-file qa.tfvars #or -var-file prod.tfvars
```

The app will be created in a stopped state, you have to manually start and stop the app for testing.

```
cf start apply-jmeter # to start the app
cf stop apply-jmeter  # to stop the app
```

Run `terraform destroy` to delete the app once your testing is complete, you can run `terraform apply` again to recreate/update the app.
