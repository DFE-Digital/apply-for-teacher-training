require 'rails_helper'

RSpec.describe RegionalReportFilter do
  describe 'associations' do
    it { is_expected.to belong_to :provider_user }
    it { is_expected.to belong_to :provider }
  end

  describe 'enums' do
    subject(:filter) { build(:regional_report_filter) }

    it {
      expect(filter).to(
        define_enum_for(:region)
        .with_values(
          west_midlands: 'West Midlands (England)',
          north_west: 'North West (England)',
          london: 'London',
          north_east: 'North East (England)',
          south_west: 'South West (England)',
          east_midlands: 'East Midlands (England)',
          east_of_england: 'East of England',
          yorkshire_and_the_humber: 'Yorkshire and The Humber',
          south_east: 'South East (England)',
          all_of_england: 'All of England',
        )
        .backed_by_column_of_type(:string),
      )
    }
  end
end
