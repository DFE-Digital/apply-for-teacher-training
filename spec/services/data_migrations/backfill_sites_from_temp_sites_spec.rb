require 'rails_helper'

RSpec.describe DataMigrations::BackfillSitesFromTempSites do
  before do
    create_list(:site, 2)
  end

  it 'does not update sites as they already exist' do
    expect { described_class.new.change }.not_to change(Site, :count)
  end
end
