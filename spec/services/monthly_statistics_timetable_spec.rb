require 'rails_helper'

RSpec.describe MonthlyStatisticsTimetable do
  describe '#generate_monthly_statistics' do
    it 'returns true if the monthly report is scheduled to run on the current date' do
      MonthlyStatisticsTimetable::DATES.each_value do |date|
        Timecop.travel(date) do
          expect(described_class.generate_monthly_statistics?).to eq true
        end
      end
    end

    it 'returns false if the monthly report is not scheduled to run on the current date' do
      MonthlyStatisticsTimetable::DATES.each_value do |date|
        date = [date - 1.day, date + 1.day].sample

        Timecop.travel(date) do
          expect(described_class.generate_monthly_statistics?).to eq false
        end
      end
    end
  end
end
