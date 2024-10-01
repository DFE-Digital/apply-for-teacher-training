require 'rails_helper'

RSpec.describe MonthlyStatisticsTimetable do
  describe '#generate_monthly_statistics?' do
    subject { described_class.generate_monthly_statistics? }

    context 'when today is the third Monday of the month' do
      months_except_october = (1..12).reject { |month| month == 10 }

      months_except_october.each do |month|
        month_name = Date::MONTHNAMES[month]
        third_monday_of_the_month = described_class.third_monday_of_the_month(Date.new(RecruitmentCycle.current_year, month, 1))

        context "in #{month_name}", time: third_monday_of_the_month do
          it { is_expected.to be_truthy }
        end
      end

      context 'in October', time: described_class.third_monday_of_the_month(Date.new(RecruitmentCycle.current_year, 10, 1)) do
        it { is_expected.to be_falsey }
      end
    end

    context "when today's date is any other day of the month" do
      (1..12).each do |month|
        month_name = Date::MONTHNAMES[month]
        date_under_test = Date.new(RecruitmentCycle.current_year, month, 1)

        context "in #{month_name}", time: date_under_test do
          it { is_expected.to be_falsey }
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
