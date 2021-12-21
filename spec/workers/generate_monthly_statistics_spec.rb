require 'rails_helper'

RSpec.describe GenerateMonthlyStatistics, sidekiq: true do
  include MonthlyStatisticsTestHelper

  it 'generates the monthly stats when the report should be generated' do
    allow(DataExporter).to receive(:perform_async).and_return true
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return true
    generate_monthly_statistics_test_data

    expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to eq(0)

    described_class.new.perform

    expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to eq(1)
  end

  it 'does not generate the monthly stats when the monthly statistics report should not be generated' do
    allow(DataExporter).to receive(:perform_async).and_return true
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return false
    expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to eq(0)

    described_class.new.perform

    expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.count).to eq(0)
  end

  it 'sets the month when generating the report' do
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return true
    generate_monthly_statistics_test_data

    described_class.new.perform

    expect(Publications::MonthlyStatistics::MonthlyStatisticsReport.first.month).to eq(Time.zone.today.strftime('%Y-%m'))
  end
end
