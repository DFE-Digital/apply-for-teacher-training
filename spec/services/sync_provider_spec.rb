require 'rails_helper'

RSpec.describe SyncProvider do
  let(:provider) { create(:provider, sync_courses: false) }

  it 'enables course syncing' do
    SyncProvider.new(provider: provider).call

    expect(provider.sync_courses).to be true
  end
end
