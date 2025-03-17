require 'rails_helper'

RSpec.describe MonthlyStatisticsTimetable do
  describe '#generate_monthly_statistics?' do
    let(:current_timetable) { RecruitmentCycleTimetable.current_timetable }
    let(:current_year) { current_timetable.recruitment_cycle_year }
    let(:find_opens_month) { current_timetable.find_opens_at.to_date.month }
    let(:report_months) { (1..12).to_a - [find_opens_month] }

    it 'returns true if the monthly report is scheduled to run on the current date' do
      report_months.each do |month|
        travel_temporarily_to(described_class.third_monday_of_the_month(Date.new(current_year, month, 1))) do
          expect(described_class.generate_monthly_statistics?).to be true
        end
      end
    end

    it 'returns false if within the first month of the cycle opening' do
      travel_temporarily_to(described_class.third_monday_of_the_month(Date.new(current_year, find_opens_month, 1))) do
        expect(described_class.generate_monthly_statistics?).to be false
      end
    end

    it 'returns false if the monthly report is not scheduled to run on the current date' do
      report_months.each do |month|
        travel_temporarily_to(current_year, month, 1) do
          expect(described_class.generate_monthly_statistics?).to be false
        end
      end
    end
  end

  describe '.next_publication_date' do
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

    context 'when today is before find opens' do
      it 'returns 4th monday in the month after find opens' do
        travel_temporarily_to(Date.new(2024, 9, 28)) do
          expect(described_class.next_publication_date).to eq(Date.new(2024, 11, 25))
        end
      end
    end
  end

  describe '#last_generation_date' do
    context 'when it in the month after find opens' do
      it 'returns date two months ago' do
        travel_temporarily_to(Date.new(2024, 11, 1)) do
          expect(described_class.last_generation_date).to eq(Date.new(2024, 9, 16))
        end
      end
    end

    context 'when it is three months after find_opens' do
      it 'returns date one month ago' do
        travel_temporarily_to(Date.new(2024, 12, 1)) do
          expect(described_class.last_generation_date).to eq(Date.new(2024, 11, 18))
        end
      end
    end
  end
end
