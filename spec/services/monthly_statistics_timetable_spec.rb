require 'rails_helper'

RSpec.describe MonthlyStatisticsTimetable do
  describe '#generate_monthly_statistics?' do
    it 'returns true if the monthly report is scheduled to run on the current date' do
      1.upto(12).each do |month|
        travel_temporarily_to(described_class.third_monday_of_the_month(Date.new(RecruitmentCycle.current_year, month, 1))) do
          expect(described_class.generate_monthly_statistics?).to be true
        end
      end
    end

    it 'returns false if the monthly report is not scheduled to run on the current date' do
      1.upto(12).each do |month|
        travel_temporarily_to(RecruitmentCycle.current_year, month, 1) do
          expect(described_class.generate_monthly_statistics?).to be false
        end
      end
    end
  end

  describe '.next_publication_date' do
    let!(:current_report) do
      create(:monthly_statistics_report, :v1, month: '2021-12')
    end
    let!(:previous_report) do
      create(:monthly_statistics_report, :v1, month: '2021-11')
    end

    context 'when today is before the publishing date in the current month' do
      it 'returns the date of this month’s report' do
        travel_temporarily_to(Date.new(2021, 12, 21)) do
          expect(described_class.next_publication_date).to eq(Date.new(2021, 12, 27))
        end
      end
    end

    context 'when today is after the publishing date in the current month' do
      it 'returns the date of next month’s report' do
        travel_temporarily_to(Date.new(2021, 12, 28)) do
          expect(described_class.next_publication_date).to eq(Date.new(2022, 1, 24))
        end
      end
    end
  end
end
