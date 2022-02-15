require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::JSONExport do
  it 'exports and imports' do
    stats = { my_table: { rows: [{ bucket_1: 10, bucket_2: 11, bucket: 3 }] } }

    Publications::MonthlyStatistics::MonthlyStatisticsReport.create(
      statistics: stats,
      month: '2021-12',
    )

    export = described_class.new('test_monthly_report.json')

    export.export!

    expect {
      export.import!('2021-01')
    }.to change { Publications::MonthlyStatistics::MonthlyStatisticsReport.count }.by(1)

    stats = Publications::MonthlyStatistics::MonthlyStatisticsReport.all.map(&:statistics)
    expect(stats.first).to eq(stats.second)
  ensure
    FileUtils.rm_rf(export.folder)
    FileUtils.rm(export.filename)
  end
end
