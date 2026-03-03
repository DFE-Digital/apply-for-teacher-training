require 'rails_helper'

RSpec.describe Publications::RegionalRecruitmentPerformanceReport do
  describe 'associations' do
    it { is_expected.to have_one :recruitment_cycle_timetable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
    it { is_expected.to validate_presence_of :region }
  end

  describe 'enums' do
    subject(:filter) { build(:regional_recruitment_performance_report) }

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
          east_of_england: 'East (England)',
          yorkshire_and_the_humber: 'Yorkshire and The Humber',
          south_east: 'South East (England)',
        )
        .backed_by_column_of_type(:string),
      )
    }
  end

  describe '.all_of_england_key' do
    it 'return all of england key' do
      expect(described_class.all_of_england_key).to eq('all_of_england')
    end
  end

  describe '.all_of_england_value' do
    it 'return all of england value' do
      expect(described_class.all_of_england_value).to eq('All of England')
    end
  end
end
