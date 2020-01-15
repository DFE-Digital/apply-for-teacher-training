require 'rails_helper'

RSpec.describe SyncAllFromFind do
  it 'calls the `SyncAllProvidersFromFind` service' do
    allow(SyncAllProvidersFromFind).to receive(:call)
    SyncAllFromFind.new.perform
    expect(SyncAllProvidersFromFind).to have_received(:call)
  end
end
