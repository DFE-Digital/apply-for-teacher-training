if Gem::Version.new(Sidekiq::VERSION) < Gem::Version.new('6.1')
  Redis.exists_returns_integer = true
else
  raise 'Time to remove Redis.exists_returns_integer: https://github.com/mperham/sidekiq/issues/4591'
end
