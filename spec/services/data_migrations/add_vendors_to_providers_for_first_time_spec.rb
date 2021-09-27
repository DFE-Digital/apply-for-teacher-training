require 'rails_helper'

RSpec.describe DataMigrations::AddVendorsToProvidersForFirstTime do
  it 'calls the UpdateVendors service' do
    allow(UpdateVendors).to receive(:call)
    described_class.new.change
    expect(UpdateVendors).to have_received(:call).once
  end
end
