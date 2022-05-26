require 'rails_helper'

RSpec.describe DataMigrations::BackfillTempSites do
  let!(:provider) { create(:provider) }

  before do
    allow(MigrateTempSitesForProvidersWorker).to receive(:perform_in)
  end

  it 'iterates through cycle years' do
    described_class.new.change

    CycleTimetable::CYCLE_DATES.reject { |year| year == CycleTimetable.next_year }.each_key do |year|
      expect(MigrateTempSitesForProvidersWorker).to have_received(:perform_in).with(anything, provider.id, year)
    end
  end
end
