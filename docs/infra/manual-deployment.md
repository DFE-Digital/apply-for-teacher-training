# How to: manually deploy Apply

This document describes the process of manually deploying to a particular environment.

## When should this process be used?

In the event that code changes are made to the app but the pipelines fail to complete the deployment stages this process should be followed to deploy the commit manually, or the main branch.

These below instructions can also be used to rollback or to deploy an arbitary commit with an build image.

This process assumes that the build and test stage has completed without error and a Docker image has been uploaded to the GitHub container registry successfully.

## Instructions using GitHub Actions

1. Grab the commit sha to be used from the [build and deploy workflow](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/build-and-deploy.yml), in case of a rollback use the commit sha of the previous commit that needs to be deployed. To deploy the `main` branch, use "main".

2. Go the [deploy-v2 workflow](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/deploy-v2.yml) and click on the "Run workflow" dropdown button. Choose the apply environment from the list.
3. Now paste the commit sha to be used in the "Commit sha to be deployed" textbox
4. Click on the "Run workflow" button, this should trigger a run workflow run and deploy the commit sha to the selected environments.

## Instructions using make commands

**NOTE: Before following the steps below you will need to request an elevation of your rights to the 'contributor' role through PIM in the Azure Portal if working on an app hosted in the test or production subscriptions. Guidance on PIM can be found in the [PIM Guide](pim-guide.md) document. PIM is not required in the development subscription.**

Make commands can be run from the root of the repo to deploy a specific version to one of the environments.

1. Grab the commit sha to be used from the [build and deploy workflow](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/build-and-deploy.yml). This is only required to deploy a particular commit instead of the current `main` branch.
1. Login to Azure via `az` cli:
    ```
    az login
    ```
1. From the root of the repo you can run the below command to deploy the app.
    ```
    make <ENV> deploy IMAGE_TAG=<COMMIT_SHA>
    eg: make qa deploy IMAGE_TAG=4ebb7d13010839b1ab2b7ae0dfef57460a5101f3
    ```
    To deploy `main`, simply use:
    ```
    make <ENV> deploy
    eg: make qa deploy
    ```

    This will list the changes about to be deployed and prompt for a confirmation, you can type "yes" to confirm and the changes will be applied.

    You can also just preview the changes by running `deploy-plan` instead of `deploy` in the above command.
1. Check the `#twd_find_and_apply_tech` Slack channel for any runtime errors from
   Sentry or the smoke tests before proceeding to the next environment.
