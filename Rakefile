# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task(:default).clear.enhance %i[run_tests]

Rake::Task['db:migrate'].enhance do
  sh 'bundle exec rake erd' if Rails.env.development?
end
