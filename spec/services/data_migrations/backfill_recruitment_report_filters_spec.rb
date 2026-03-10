require 'rails_helper'

RSpec.describe DataMigrations::BackfillRecruitmentReportFilters do
  it 'sets the recruitment cycle year to 2026' do
    create(:regional_report_filter)

    described_class.new.change
    expect(RegionalReportFilter.distinct.pluck(:recruitment_cycle_year)).to contain_exactly(2026)
  end
end
