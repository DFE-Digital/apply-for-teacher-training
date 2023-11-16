require 'rails_helper'

RSpec.describe GenerateMonthlyStatistics, :sidekiq do
  include DfE::Bigquery::TestHelper
  before { stub_bigquery_application_metrics_request }

  context 'when second Monday of the month' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 13))
    end

    it 'returns false' do
      expect(described_class.new.perform).to be false
      expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to be_zero
    end
  end

  context 'when fourth Monday of the month' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 27))
    end

    it 'returns false' do
      expect(described_class.new.perform).to be false
      expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to be_zero
    end
  end

  context 'when third Monday of the month' do
    subject(:report) { Publications::MonthlyStatistics::MonthlyStatisticsReport.first }

    before do
      TestSuiteTimeMachine.travel_permanently_to(2023, 11, 20)
    end

    it 'generates new monthly statistics report' do
      described_class.new.perform
      expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to be 1
      expect(report.month).to eq('2023-11')
      expect(report.generation_date).to eq(Date.new(2023, 11, 20))
      expect(report.publication_date).to eq(Date.new(2023, 11, 27))
      expect(report.statistics.keys).to eq(%w[meta data])
      expect(report.statistics['data'].keys).to eq(%w[
        candidate_headline_statistics
        candidate_age_group
        candidate_sex
        candidate_area
        candidate_phase
        candidate_route_into_teaching
        candidate_primary_subject
        candidate_secondary_subject
        candidate_provider_region
      ])
    end
  end
end
