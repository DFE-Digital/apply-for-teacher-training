desc 'Lint ruby code'
namespace :lint do
  task :ruby do
    puts 'Linting ruby...'
    system 'bundle exec rubocop'
  end
end
