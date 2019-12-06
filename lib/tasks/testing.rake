begin
  require 'rspec/core/rake_task'

  performance_test_pattern = 'spec/performance/**/*.rb'
  RSpec::Core::RakeTask.new(:spec_without_performance) do |t|
    t.rspec_opts = "--exclude-pattern #{performance_test_pattern}"
  end

  RSpec::Core::RakeTask.new(:spec_with_profile) do |t|
    t.rspec_opts = "--profile --exclude-pattern #{performance_test_pattern}"
  end

  integration_test_pattern = 'spec/{system,requests}/**/*_spec.rb'

  RSpec::Core::RakeTask.new(:rspec_acceptance_tests) do |t|
    t.rspec_opts = "--pattern #{integration_test_pattern}"
  end

  RSpec::Core::RakeTask.new(:unit_tests) do |t|
    t.rspec_opts = "--exclude-pattern #{integration_test_pattern} --exclude-pattern #{performance_test_pattern}"
  end
rescue LoadError
  nil
end

desc 'Run brakeman'
task :brakeman do
  require 'brakeman'
  Brakeman.run(app_path: '.', print_report: true)
end

desc 'Run rubocop'
task :rubocop do
  system 'bundle exec rubocop --parallel'
end

desc 'Lint all *.erb* files in app/views using erblint'
task :erblint do
  system 'erblint app/views'
end

desc 'Run all the linters'
task linting: %i[rubocop erblint]

desc 'Run all acceptance tests'
task acceptance_tests: %i[rspec_acceptance_tests cucumber]

desc 'Run all the tests'
task run_tests: %i[linting spec_without_performance brakeman]
