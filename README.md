[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Apply/apply-for-postgraduate-teacher-training?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=49&branchName=master)

# Apply for postgraduate teacher training

This service enables postgraduate candidates to apply for initial teacher
training.

## Table of Contents

* [Dependencies](#dependencies)
* [Prerequisites for development](#dev-prerequisites)
* [Setting up the development environment](#dev-env-setup)
* [Docker workflow](#docker-workflow)
* [Webpacker](#webpacker)
  * [Debugging Webpacker](#webpacker-debug)
* [Documentation](#documentation)
  * [Nomenclature](#documentation-nomenclature)
  * [Domain Model](#documentation-domain-model)
  * [Application States](#documentation-application-states)
  * [Environment Variables](#documentation-env-vars)

## <a name="dependencies"></a>Dependencies

- Ruby 2.6.3
- NodeJS 8.11.x
- Yarn 1.12.x
- PostgreSQL 9.6
- Graphviz 2.22+ (`brew install graphviz`) to generate the [domain model diagram](#domain-model)

## <a name="dev-prerequisites"></a>Prerequisites for development

`docker` and `docker-compose`

## <a name="dev-env-setup"></a>Setting up the development environment

1. Copy `.env.example` to `.env` and fill in the secrets
1. Run `make setup`
1. Run `make serve` to launch the app on https://localhost:3000

See `Makefile` for the steps involved in building and running the app.

## <a name="docker-workflow"></a>Docker Workflow

Under `docker-compose`, the database uses a Docker volume to persist
storage across `docker-compose up`s and `docker-compose down`s. For
want of cross-platform compatibility between JavaScript libraries, the
app's `node_modules` folder is also stored in a persistent Docker
volume.

Running `make setup` will blow away and recreate those volumes,
destroying any data you have created in development. It is necessary
to run it at least once before the app will boot in Docker.

## <a name="webpacker"></a>Webpacker

We do not use the Rails asset pipeline. We use the Rails webpack wrapper
[Webpacker](https://github.com/rails/webpacker) to compile our CSS, images, fonts
and JavaScript.

### <a name="webpacker-debug"></a>Debugging Webpacker

Webpacker sometimes doesn't give clear indications of what's wrong when it
doesn't work.

**If you see repeated 'Webpacker compiling...' messages in the Rails server
log**, a good place to start debugging is by running the webpack compiler via
`bin/webpack`. This will give a much faster feedback loop than making requests
using a web browser.

**If you get `Webpacker::Manifest::MissingEntryError`s**, this usually points
to a problem in the compilation process which is causing one or more files not
to be created. Make sure that your yarn packages are up to date using `yarn
check` before proceeding to debug using `bin/webpack`.

**If assets work in dev but not in tests**, first confirm that you can compile
by invoking `bin/webpack`. If all is well, there is a chance that
`public/packs-test` contains stale output. Delete it and re-run the suite.

## <a name="documentation"></a>Documentation

### <a name="documentation-nomenclature"></a>Nomenclature
- **Course** consists of a UCAS provider code and a UCAS course code. In our system, this is represented by the `ucas_provider_code` and `ucas_course_code` on the `ApplicationChoice` model
- **Course Choice** is the course plus a training location code, in our system represented by `ucas_provider_code`, `ucas_course_code`, `ucas_location_code`

### <a name="documentation-domain-model"></a>Domain Model

![The domain model for this application](docs/domain-model.png)

Regenerate this diagram with `bundle exec erd`.

### <a name="documentation-application-states"></a>Application states

![All of the states and transitions in the app](docs/states.png)

Regenerate this diagram with `bundle exec rake generate_state_diagram`.

### <a name="documentation-env-vars"></a>Environment Variables

**NOTE: Environment variables should not start with *endpoint*, *input*, *secret*, or *securefile* (irrespective of capitalisation) due to them being protected variable names within the Azure DevOps environment.** If this cannot be avoided variable mapping will have to be used, but wherever possible it is simpler not to use these protected names.

Environment variables have to be defined in several places depending upon where they are required, some are common to both local development and the Azure hosted deployment, while others are specific to the envirionments they relate, all of which are described below

#### <a name="documentation-env-vars-dockerfile"></a>Dockerfile

If an environment variable is required during the Docker image build, like for example in the Rails asset compilation process, these should be defined in the Dockerfile in the following format.

`ENV VARIABLE_NAME=Value`

When defining variables in the Dockerfile use dummy values for security reasons since they will be committed to Git and they will ultimately be overriden by docker-compose when you launch a container using the image.

#### <a name="documentation-env-vars-local-dev"></a>Local Development

If an environment variable is required for use in the local development environment it should be declared in the .env file in the following format

`VARIABLE_NAME=Value`

The [.env.example](./.env.example) file contains the essential environment variables that must exist for local development builds to succeed.

#### <a name="documentation-env-vars-docker-compose"></a>Docker Compose

For docker compose to make the necessary environment variables available in the container at run time they must be declared in the relevant docker-compose.yaml file, of which there are three.

* [docker-compose.yml](./docker-compose.yml) - Variables that are required for local dev and the docker image build phase in azure only should be defined the *environment* section in this file. This will in general only be for the database.
* [docker-compose.override.yml](./docker-compose.override.yml) - This file is used exclusively for local development. No further changes are required here.
* [docker-compose.azure.yml](./docker-compose.azure.yml) - This file is exclusively used in the Azure devops pipeline. Any environment variables required in the Azure build/deployment need to be declared in the *environment* section of this file. **You should only declare the environment variable here, not its value.** The only exception to this is where we need to map variables due to the use of protected variable names, e.g. Rails SECRET_KEY_BASE.

#### <a name="documentation-env-vars-azure-devops"></a>Azure Hosting (DevOps pipeline)

These steps describe the process for making environment variables available to the the Azure DevOps pipeline.

1. Declare the desired variable in the appropriate "variable group" in the Library section of the Azure DevOps site (https://dfe-ssp.visualstudio.com/Become-A-Teacher/_library?itemType=VariableGroups). All variable groups related to apply are suffixed as such and there is a variable group per deployment environment.
1. In the [azure-pipelines.yml](./azure-pipelines.yml) file there are several changes to be made:
   1. For each "make" command script step, add your environment variable to the *env* section in the format `ENV_VAR_NAME: $(varName)` where **ENV_VAR_NAME** is the environment variable name as it should appear in the docker container and **varName** is the name of the variable defined in the Azure DevOps variable group.
   1. For each 'deployment stage' you must add your variable to the template *parameters* section in the format `varName: '$(varName)'`.
1. In the [azure-pipelines-deploy-template.yaml](./azure-pipelines-deploy-template.yml) file you need to make the following additions:
   1. Add your variable to the *parameters* section at the start of the file using the name of the variable as it appears in the variable group.
   1. In the Azure Resource Group deployment task *overrideParameters* section add your variable in the format `-varName: "${{parameters.varName}}"`
1. In the [azure/template.json](./azure/template.json) file you need to make the following additions:
   1. Duplicate this block of code for your new variable in the *parameters* section at the start of the file.
      ```
	  "varName": {
       "type": "string",
        "metadata": {
          "description": "Describe your variable here."
        }
      }
      ```
   1. Around line 180 duplicate this block of into the *appServiceAppSettings* section.
      ```
	  {
        "name": "ENV_VAR_NAME",
        "value": "[parameters('varName')]"
      }
      ```
