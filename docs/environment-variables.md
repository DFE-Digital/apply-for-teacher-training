# Environment Variables

**NOTE: Environment variables should not start with *endpoint*, *input*, *secret*, or *securefile* (irrespective of capitalisation) due to them being protected variable names within the Azure DevOps environment.** If this cannot be avoided variable mapping will have to be used, but wherever possible it is simpler not to use these protected names.

Environment variables have to be defined in several places depending upon where they are required, some are common to both local development and the Azure hosted deployment, while others are specific to the environments they relate, all of which are described below

## Dockerfile

If an environment variable is required during the Docker image build, like for example in the Rails asset compilation process, these should be defined in the Dockerfile in the following format.

`ENV VARIABLE_NAME=Value`

When defining variables in the Dockerfile use dummy values for security reasons since they will be committed to Git and they will ultimately be overriden by docker-compose when you launch a container using the image.

## Local Development

If an environment variable is required for use in the local development environment it should be declared in the .env file in the following format

`VARIABLE_NAME=Value`

The [.env.example](./.env.example) file contains the essential environment variables that must exist for local development builds to succeed.

## Docker Compose

For docker compose to make the necessary environment variables available in the container at run time they must be declared in the relevant docker-compose.yaml file, of which there are three.

* [docker-compose.yml](./docker-compose.yml) - Variables that are required for local dev and the docker image build phase in azure only should be defined the *environment* section in this file. This will in general only be for the database.
* [docker-compose.override.yml](./docker-compose.override.yml) - This file is used exclusively for local development. No further changes are required here.
* [docker-compose.azure.yml](./docker-compose.azure.yml) - This file is exclusively used in the Azure devops pipeline. Any environment variables required in the Azure build/deployment need to be declared in the *environment* section of this file. **You should only declare the environment variable here, not its value.** The only exception to this is where we need to map variables due to the use of protected variable names, e.g. Rails SECRET_KEY_BASE.

## Azure Hosting (DevOps pipeline)

These steps describe the process for making environment variables available to the the Azure DevOps pipeline.

1. Declare the desired variable in the appropriate "variable group" in the Library section of the Azure DevOps site (https://dfe-ssp.visualstudio.com/Become-A-Teacher/_library?itemType=VariableGroups). All variable groups related to apply are suffixed as such and there is a variable group per deployment environment.
1. In the [azure-pipelines.yml](./azure-pipelines.yml) and [azure-pipelines-release.yml](./azure-pipelines-release.yml) file there are several changes to be made:
   1. (Applies to [azure-pipelines.yml](./azure-pipelines.yml) only) For each "make" command script step, add your environment variable to the *env* section in the format `ENV_VAR_NAME: $(varName)` where **ENV_VAR_NAME** is the environment variable name as it should appear in the docker container and **varName** is the name of the variable defined in the Azure DevOps variable group.
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
   1. Around line 505 duplicate this block of code in the *appEnvironmentVariables* parameter of the `app-service-and-containers` resource and configure it to match your new environment varaible. If the environment variable in question contains a secret, change `value` to `secureValue`.
      ```
      {
        "name": "ENV_VAR_NAME",
        "value": "[parameters('varName')]"
      }
      ```
