# How to: deploy Apply

The apply [build and deploy workflow](https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/.github/workflows/build-and-deploy.yml) runs via Github Actions.

It will automatically trigger a build from a commit to the `main` branch, this pipeline is also run on the merged PR head commit when a pull request is raised targetting `main`. If run from `main` branch this also triggers the deployment job after all tests have succeeded.

Pull Requests that have the `deploy` label applied will trigger the deployment of a short lived Review App to its own self contained environment.  This provides an opportunity to manually review the changes prior to merging them to `main`, once the PR has been merged the Review App and its environment will be deleted.

Continuous Deployment is enabled so a successful build on `main` triggers deployments to all environments including `production`. Rolling deployment is used to achieve zero-downtime deployments. This means 2 versions of the code run at the same time and pointing at the same database. The database schema must work for both versions. Make sure to never commit code changes alongside a migration. They should be separate to avoid errors.

Deployments can be triggered manually and the target environments can be chosen prior to deployment, see the [Manual Deployment guide](manual-deployment.md) for instructions.

You also have to make sure that you’re only merging changes that are safe to deploy. Changes that are not yet ready for production should be behind a feature flag.

In case of an incident or planned maintenance, the maintenance page can be enabled. Refer to [the main maintenance page documentation](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/maintenance-page.md) for help.
