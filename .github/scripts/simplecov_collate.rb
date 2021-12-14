require 'simplecov'

SimpleCov.root '/app'

SimpleCov.collate Dir['*-result/.resultset.json'], 'rails' do
  enable_coverage :branch
end
