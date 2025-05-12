require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReport do
  describe 'associations' do
    it { is_expected.to belong_to :provider }
    it { is_expected.to have_one :recruitment_cycle_timetable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
  end

  describe '#reporting_end_date' do
    it "returns the date of the last day of the cycle week based on the report's recruitment cycle 2024" do
      report = build(:provider_recruitment_performance_report, cycle_week: 35, recruitment_cycle_year: 2024)
      expect(report.reporting_end_date).to eq(Date.new(2024, 6, 2))
    end

    it "returns the date of the last day of the cycle week based on the report's recruitment cycle 2025" do
      report = build(:provider_recruitment_performance_report, cycle_week: 35, recruitment_cycle_year: 2025)
      expect(report.reporting_end_date).to eq(Date.new(2025, 6, 1))
    end
  end
end
