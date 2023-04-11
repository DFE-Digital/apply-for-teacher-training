# Developing in GitHub Codespaces

Navigate to your branch in Github, select 'Code' and create a new codespace. This will create a virtual machine specific to the branch, running Postgres, Redis etc.

## Test data

If you want a reasonable set of test data, enter the following command in the terminal: `bundle exec rake setup_local_dev_data`

## Viewing the support console

To view the support console, you'll need to have a SupportUser set up. If you've already run `setup_local_dev_data`, this has already happened. If not, open a Rails console (see below) and run `SupportUser.create(dfe_sign_in_uid: 'dev-support', email_address: 'support@example.com')`

## Making your codespace visible to other team members

- Go to the Ports tab
- The website will be running on port 5000
- The context menu for the port will give you the option to adjust 'port visibility'. "Private to Organization" is probably the right option here

## Running tests

- Open a new terminal (`+` button)
- Run `bundle exec rspec spec/path-to-tests`

## Modifying data in a Rails console

- Open a new terminal (`+` button)
- Run `bundle exec rails console`
- Now you can do things like `ApplicationForm.first.update(first_name: 'Falafel')`

## Live Share

In order to create a Live Share session that multiple people can work on simultaneously:

- Open the 'extensions' tab
- Search for 'Live Share', and install it
- In the status bar, click the 'Live Share' icon
- A URL will be generated. Copy this and share it with the other people you want to work with

## Fetching latest changes to the branch

If there have been changes to the branch since you created the codespace, you can fetch them by:

- Open a new terminal (`+` button)
- Run `git pull`

## Gotchas

- The codespace will send emails with application URLs relative to http://localhost:3000, as we are running in development mode. For example, when you receive a magic link, you'll need to copy the path and change the host to whatever Codespaces has generated for you.
- When the container shuts down, it will end the Rails and Sidekiq processes. When you log back in again, you can restart them:
`bundle exec puma -C config/puma.rb & bundle exec sidekiq -c 5 -C config/sidekiq-main.yml`
