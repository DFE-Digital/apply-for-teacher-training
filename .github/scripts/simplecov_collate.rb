require 'simplecov'

SimpleCov.root '/app'

SimpleCov.collate Dir['*-coverage/.resultset.json'], 'rails' do
  enable_coverage :branch
end
