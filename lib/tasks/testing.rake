begin
  require 'rspec/core/rake_task'

  performance_test_pattern = 'spec/performance/**/*.rb'
  RSpec::Core::RakeTask.new(:spec_without_performance) do |t|
    t.rspec_opts = "--exclude-pattern #{performance_test_pattern} --format progress"
  end

  RSpec::Core::RakeTask.new(:spec_with_profile) do |t|
    t.rspec_opts = "--profile --exclude-pattern #{performance_test_pattern}"
  end

  integration_test_pattern = 'spec/{system,requests}/**/*_spec.rb'
  RSpec::Core::RakeTask.new(:acceptance_tests) do |t|
    t.rspec_opts = "--pattern #{integration_test_pattern} --format progress"
  end

  RSpec::Core::RakeTask.new(:unit_tests) do |t|
    t.rspec_opts = "--exclude-pattern '#{integration_test_pattern},#{performance_test_pattern}' --format progress"
  end

  RSpec::Core::RakeTask.new(:performance_tests) do |t|
    t.rspec_opts = "--profile --pattern #{performance_test_pattern} --format progress"
  end
rescue LoadError
  nil
end

desc 'Run JS unit tests'
task :jest do
  sh 'yarn jest --coverage'
end

desc 'Run Brakeman'
task :brakeman do
  sh 'bundle exec brakeman'
end

desc 'Run Rubocop'
task :rubocop do
  sh 'bundle exec rubocop --parallel'
end

desc 'Run ERB Lint'
task :erb_lint do
  sh 'bundle exec erb_lint --lint-all'
end

desc 'Run Stylelint'
task :stylelint do
  sh 'yarn run lint:css'
end

desc 'Run Standard JS Linter'
task :lint_js do
  sh 'yarn run lint'
end

desc 'Run all the linters'
task linting: %i[rubocop erb_lint stylelint lint_js]

desc 'Run rspec in parallel without performance'
task :parallel_rspec_without_performance do
  sh "bundle exec parallel_rspec --exclude-pattern=#{performance_test_pattern} spec"
end

desc 'Run all the tests'
task run_tests: %i[linting parallel_rspec_without_performance brakeman jest]
