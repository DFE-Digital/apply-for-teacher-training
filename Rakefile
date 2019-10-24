# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task lint_ruby: ['lint:ruby']

task(:default).clear

task :brakeman do
  require 'brakeman'
  Brakeman.run(app_path: '.', print_report: true)
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec_with_profile) do |t|
    t.rspec_opts = '--profile'
  end
rescue LoadError
  nil
end

task default: %i[lint_erb lint_ruby spec_with_profile generate_state_diagram brakeman]

Rake::Task['db:migrate'].enhance do
  sh 'bundle exec erd' if Rails.env.development?
end
