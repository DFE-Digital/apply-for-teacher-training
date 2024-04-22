# How to: deploy Apply

The apply build and release process is split into two separate GitHub Actions pipelines.

- [Build](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/build.yml): This is the main CI pipeline which will automatically trigger a build from a commit to the `main` branch, this pipeline is also run on the merged PR head commit when a pull request is raised targetting `main`. If run from `main` branch this also triggers the deployment pipeline after all tests have succeeded.

- [Deploy](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/deploy.yml): This is the main release pipeline that is used to deploy to all environments.
    - Pull Requests that have the `deploy` label applied will trigger the deployment of a short lived Review App to its own self contained environment.  This provides an opportunity to manually review the changes prior to merging them to `main`, once the PR has been merged the Review App and its environment will be deleted.
    - Continuous Deployment is enabled so a successful build on `main` triggers deployments to all environments including `production`.
    - Deployments can be triggered manually and the target environments can be chosen prior to deployment, see the [Manual Deployment guide](manual-deployment.md) for instructions.

The [Apply Ops Dashboard](https://apply-ops-dashboard.azurewebsites.net) provides an overview of what is currently deployed in each environment.

You also have to make sure that you’re only merging changes that are safe to deploy. Changes that are not yet ready for production should be behind a feature flag.
