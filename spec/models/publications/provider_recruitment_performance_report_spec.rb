require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReport do
  describe 'associations' do
    it { is_expected.to belong_to :provider }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
  end

  describe '#reporting_end_date' do
    it 'returns the date of the last day of the cycle week', time: Time.zone.local(2024, 6, 6) do
      report = create(:provider_recruitment_performance_report, cycle_week: 35)
      expect(report.reporting_end_date).to eq(Date.new(2024, 6, 2))
    end
  end
end
