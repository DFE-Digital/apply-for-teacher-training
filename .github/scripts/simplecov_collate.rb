require 'simplecov'

SimpleCov.root '/app'

SimpleCov.start do
  enable_coverage :branch
end

SimpleCov.collate Dir['*-result/.resultset.json']
