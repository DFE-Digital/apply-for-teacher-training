require 'rails_helper'

RSpec.describe DataMigrations::MonthlyReportsBackfill do
  it 'backfill adding the generation date' do
    stats = { my_table: { rows: [{ bucket_1: 10, bucket_2: 11, bucket: 3 }] } }

    described_class::GENERATION_DATES.each do |month, _expected_date|
      Publications::MonthlyStatistics::MonthlyStatisticsReport.create(
        statistics: stats,
        month:,
      )
    end

    described_class.new.change

    described_class::GENERATION_DATES.each do |month, expected_date|
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.find_by(month:)

      expect(report.generation_date).to eq(expected_date)
    end
  end

  it 'backfill adding the publication date' do
    stats = { my_table: { rows: [{ bucket_1: 10, bucket_2: 11, bucket: 3 }] } }

    described_class::GENERATION_DATES.each do |month, _expected_date|
      Publications::MonthlyStatistics::MonthlyStatisticsReport.create(
        statistics: stats,
        month:,
      )
    end

    described_class.new.change

    described_class::PUBLISHING_DATES.each do |month, expected_date|
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.find_by(month:)

      expect(I18n.l(report.publication_date)).to eq(I18n.l(expected_date))
    end
  end
end
