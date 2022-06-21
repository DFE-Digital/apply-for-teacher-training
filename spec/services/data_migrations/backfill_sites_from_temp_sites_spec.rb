require 'rails_helper'

RSpec.describe DataMigrations::BackfillSitesFromTempSites do
  before do
    create_list(:site, 2)
  end

  it 'creates Sites to match TempSites' do
    expect { described_class.new.change }.to change { Site.count }.from(0).to(2)
  end
end
