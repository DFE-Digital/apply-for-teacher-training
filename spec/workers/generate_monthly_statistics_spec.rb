require 'rails_helper'

RSpec.describe GenerateMonthlyStatistics, :sidekiq do
  include DfE::Bigquery::TestHelper

  context 'not production' do
    it 'returns false' do
      expect(described_class.new.perform).to be false
    end
  end

  context 'production' do
    before do
      allow(HostingEnvironment).to receive(:production?).and_return true
      stub_bigquery_application_metrics_request
    end

    context 'when third Monday, but within the first month of the cycle' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2024, 10, 21))
      end

      it 'returns false' do
        expect(described_class.new.perform).to be false
        expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to be_zero
      end
    end

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
        expect(report.statistics.keys).to eq(%w[meta data formats])
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
          candidate_provider_region_and_subject
          candidate_area_and_subject
        ])
      end
    end

    context 'when forcing the report' do
      subject(:report) { Publications::MonthlyStatistics::MonthlyStatisticsReport.first }

      before do
        TestSuiteTimeMachine.travel_permanently_to(2025, 10, 21)
      end

      it 'generates new monthly statistics report' do
        described_class.new.perform(true)
        expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to be 1
        expect(report.month).to eq('2025-10')
        expect(report.generation_date).to eq(Date.new(2025, 10, 21))
        expect(report.publication_date).to eq(Date.new(2025, 10, 28))
        expect(report.statistics.keys).to eq(%w[meta data formats])
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
          candidate_provider_region_and_subject
          candidate_area_and_subject
        ])
      end
    end
  end
end
