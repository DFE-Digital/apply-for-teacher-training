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
