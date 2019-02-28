desc 'Lint ruby code'
namespace :lint do
  task :ruby do
    puts 'Linting ruby...'
    system 'bundle exec govuk-lint-ruby app config db lib spec Gemfile --format clang -a'
  end

  task :scss do
    puts 'Linting scss...'
    system 'bundle exec govuk-lint-sass app/webpacker/stylesheets'
  end
end
