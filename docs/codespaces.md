# Developing in GitHub Codespaces

Navigate to your branch in Github, select 'Code' and create a new codespace. This will create a virtual machine specific to the branch, running Postgres, Redis etc.

Once the codespace has loaded, you'll need to run Sidekiq in order to process background jobs (such as sending emails) and run the Rails website.

## Running Sidekiq

- Go to the Terminal tab
- Run `SERVICE_TYPE=worker bundle exec sidekiq -c 5 -C config/sidekiq-main.yml`

## Running the Apply website

- Open a new terminal (`+` button)
- Run `bundle exec rails server`
- After a few seconds, you should see a notification that the app is running, with an option to open in browser

## Making your codespace visible to other team members

- Go to the Ports tab
- The website will be running on port 3000
- The context menu for the port will give you the option to adjust 'port visibility'. "Private to Organization" is probably the right option here

## Running tests

- Open a new terminal (`+` button)
- Run `bundle exec rspec spec/path-to-tests`

## Modifying data in a Rails console

- Open a new terminal (`+` button)
- Run `bundle exec rails console`
- Now you can do things like `ApplicationForm.first.update(first_name: 'Falafel')`

## Gotchas

- The codespace will send emails with application URLs relative to http://localhost:3000. Thus for example when you receive a magic link, you'll need to copy the URL and change the host to whatever Codespaces has generated for you.
