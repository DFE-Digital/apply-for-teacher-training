require 'rails_helper'

RSpec.describe WizardStateStores::RedisStore do
  it 'stores the value', :with_cache do
    key = 'any_old_key'
    store = described_class.new(key:)

    value = 'value'
    store.write(value)

    expect(Rails.cache.read(key)).to eq(value)
  end
end
