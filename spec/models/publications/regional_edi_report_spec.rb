require 'rails_helper'

RSpec.describe Publications::RegionalEdiReport do
  describe 'associations' do
    it { is_expected.to have_one :recruitment_cycle_timetable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
    it { is_expected.to validate_presence_of :region }
    it { is_expected.to validate_presence_of :category }
  end

  describe 'enums' do
    subject(:regional_edi) { build(:regional_edi_report) }

    it {
      expect(regional_edi).to(
        define_enum_for(:category)
        .with_values(
          ethnic_group: 'Ethnic group',
          sex: 'Sex',
          age_group: 'Age group',
          disability: 'Disability',
        )
        .backed_by_column_of_type(:string),
      )
    }

    it {
      expect(regional_edi).to(
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
