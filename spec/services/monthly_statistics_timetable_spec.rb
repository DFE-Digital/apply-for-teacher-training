require 'rails_helper'

RSpec.describe MonthlyStatisticsTimetable do
  describe '#generate_monthly_statistics' do
    it 'returns true if the monthly report is scheduled to run on the current date' do
      MonthlyStatisticsTimetable::GENERATION_DATES.each_value do |date|
        Timecop.travel(date) do
          expect(described_class.generate_monthly_statistics?).to eq true
        end
      end
    end

    it 'returns false if the monthly report is not scheduled to run on the current date' do
      MonthlyStatisticsTimetable::GENERATION_DATES.each_value do |date|
        date = [date - 1.day, date + 1.day].sample

        Timecop.travel(date) do
          expect(described_class.generate_monthly_statistics?).to eq false
        end
      end
    end
  end

  describe '#current_reports_generation_date' do
    context 'when the most recent generation date is within the same month' do
      it 'returns the correct value' do
        Timecop.travel(described_class::GENERATION_DATES.values.first + 1.day) do
          expect(described_class.current_reports_generation_date).to eq described_class::GENERATION_DATES.values.first
        end
      end
    end

    context 'when the most recent generation date was last month' do
      it 'returns the correct value' do
        Timecop.travel(described_class::GENERATION_DATES.values.second - 1.day) do
          expect(described_class.current_reports_generation_date).to eq described_class::GENERATION_DATES.values.first
        end
      end
    end
  end

  describe '#in_qa_period?' do
    context 'when it is before the generation date for the current month' do
      it 'returns false' do
        Timecop.travel(described_class::GENERATION_DATES.values.third - 1.day) do
          expect(described_class.in_qa_period?).to eq false
        end
      end
    end

    context 'when it is after the publish date for the current month' do
      it 'returns false' do
        Timecop.travel(described_class::PUBLISHING_DATES.values.third + 1.day) do
          expect(described_class.in_qa_period?).to eq false
        end
      end
    end

    context 'when it is between the generation and publish dates for the current month' do
      it 'returns true' do
        Timecop.travel(described_class::GENERATION_DATES.values.third + 1.day) do
          expect(described_class.in_qa_period?).to eq true
        end
      end
    end
  end

  describe '#report_for_current_period' do
    let!(:current_report) { Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: '2021-12') }
    let!(:previous_report) { Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: '2021-11') }

    context 'when today is before the publishing date in the current month' do
      it 'returns the previous report' do
        Timecop.freeze(Date.new(2021, 12, 21)) do
          expect(described_class.report_for_current_period).to eq(previous_report)
        end
      end
    end

    context 'when today is after the publishing date in the current month' do
      it 'returns the previous report' do
        Timecop.freeze(Date.new(2021, 12, 28)) do
          expect(described_class.report_for_current_period).to eq(current_report)
        end
      end
    end
  end

  describe '#current_exports' do
    context 'when it is not between the generation and publish date' do
      it 'returns the latest set of MonthlyStatistics exports' do
        allow(described_class).to receive(:in_qa_period?).and_return false
        expected_exports = []

        DataExport::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
          create(:data_export, export_type: export_type)
          expected_exports << create(:data_export, export_type: export_type)
        end

        expect(described_class.current_exports).to eq expected_exports
      end
    end

    context 'when it is between the generation and publish date for the current month' do
      it 'returns the latest set of MonthlyStatistics exports' do
        allow(described_class).to receive(:in_qa_period?).and_return true
        expected_exports = []

        DataExport::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
          expected_exports << create(:data_export, export_type: export_type)
          create(:data_export, export_type: export_type)
        end

        expect(described_class.current_exports).to eq expected_exports
      end
    end
  end
end
