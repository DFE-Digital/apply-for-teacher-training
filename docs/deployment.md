# How to: deploy Apply

The apply build and release process is split into two separate GitHub Actions pipelines.

- [Build](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/build.yml): This is the main CI pipeline which will automatically trigger a build from a commit to the `main` branch, this pipeline is also run on the merged PR head commit when a pull request is raised targetting `main`. If run from `main` branch this also triggers the deployment pipeline after all tests have succeeded.

- [Deploy](https://github.com/DFE-Digital/apply-for-teacher-training/actions/workflows/deploy.yml): This is the main release pipeline that is used to deploy to all environments. Releases to `production` are triggered manually and the target environments can be chosen prior to deployment.

Go to [the Apply Ops Dashboard](https://apply-ops-dashboard.azurewebsites.net) and find the commit you want to deploy
and check the diff on GitHub to see if there's anything risky.

You also have to make sure that you're deploying only work that is safe to deploy. It should be either behind a feature flag or product reviewed, see the [Manual Deployment guide](manual-deployment.md) for instructions.
