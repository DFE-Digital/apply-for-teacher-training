require 'rails_helper'

RSpec.describe CacheKey do
  let(:identifier) { 'any old string' }

  it 'differs by code revision' do
    stub_const('CODE_REVISION_FOR_CACHE', 'sha-before')
    old_key = described_class.generate(identifier)

    stub_const('CODE_REVISION_FOR_CACHE', 'sha-after')
    new_key = described_class.generate(identifier)

    expect(old_key).not_to eq(new_key)
  end

  it 'differs by feature flag age' do
    old_key = described_class.generate(identifier)

    # when feature flags are enabled in advance
    # this can result in the newly created flag having
    # the same updated_at as an existing flag
    Timecop.travel(1.second.from_now) { create(:feature) }

    new_key = described_class.generate(identifier)

    expect(old_key).not_to eq(new_key)
  end

  it 'differs by the passed identifier' do
    old_key = described_class.generate(identifier)

    new_key = described_class.generate('banana')

    expect(old_key).not_to eq(new_key)
  end
end
