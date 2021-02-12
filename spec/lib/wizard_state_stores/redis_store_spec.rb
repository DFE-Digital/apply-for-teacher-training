require 'rails_helper'

RSpec.describe WizardStateStores::RedisStore do
  it 'expires the key after 24 hours' do
    store = described_class.new(key: 'any_old_key')

    store.write('value')

    redis = Redis.current
    expect(redis.ttl('any_old_key')).to be_within(5).of(1.day.to_i)
  end
end
