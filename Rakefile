# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task lint_ruby: ['lint:ruby']

task(:default).clear

task default: %i[lint_erb lint_ruby spec cucumber]

Rake::Task['db:migrate'].enhance do
  sh 'bundle exec erd'
end
