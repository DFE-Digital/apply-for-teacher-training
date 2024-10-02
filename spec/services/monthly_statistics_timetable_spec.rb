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

RSpec.describe MonthlyStatisticsTimetable::Timetable do
  describe '#generate_monthly_statistics?' do
    subject { described_class.new(base_date).generate_monthly_statistics? }

    context 'when base date is the third Monday of the month' do
      months_except_october = (1..12).reject { |month| month == 10 }

      months_except_october.each do |month|
        month_name = Date::MONTHNAMES[month]
        let(:base_date) { MonthlyStatisticsTimetable.third_monday_of_the_month(Date.new(RecruitmentCycle.current_year, month, 1)) }

        context "in #{month_name}" do
          it { is_expected.to be_truthy }
        end
      end

      context 'in October' do
        let(:base_date) { MonthlyStatisticsTimetable.third_monday_of_the_month(Date.new(RecruitmentCycle.current_year, 10, 1)) }

        it { is_expected.to be_falsey }
      end
    end

    context 'when base date is the first day of the month' do
      (1..12).each do |month|
        month_name = Date::MONTHNAMES[month]

        context "in #{month_name}" do
          let(:base_date) { Date.new(RecruitmentCycle.current_year, month, 1) }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#current_month_generation_date' do
    subject(:current_month_generation_date) { described_class.new(base_date).current_month_generation_date }

    context 'when the base date is the first day of the month' do
      let(:base_date) { Date.new(2021, 12, 1) }
      let(:third_monday_of_the_month) { Date.new(2021, 12, 20) }

      it { is_expected.to eq(third_monday_of_the_month) }
    end

    context 'when the base date is the third Monday of the month' do
      let(:base_date) { Date.new(2021, 12, 20) }
      let(:third_monday_of_the_month) { Date.new(2021, 12, 20) }

      it { is_expected.to eq(third_monday_of_the_month) }
    end

    context 'when the base date is the last day of the month' do
      let(:base_date) { Date.new(2021, 12, 31) }
      let(:third_monday_of_the_month) { Date.new(2021, 12, 20) }

      it { is_expected.to eq(third_monday_of_the_month) }
    end

    context 'when the base date is in October' do
      let(:base_date) { Date.new(2021, 10, 1) }

      it 'is expected to be the third Monday of September' do
        third_monday_of_september = Date.new(2021, 9, 20)

        expect(current_month_generation_date).to eq(third_monday_of_september)
      end
    end
  end

  describe '#current_month_publication_date' do
    subject(:current_month_publication_date) { timetable.current_month_publication_date }

    let(:timetable) { described_class.new }

    before do
      allow(timetable).to receive(:current_month_generation_date)
                            .and_return(Date.new(2021, 1, 1))
    end

    it 'a date one week after the current generation date' do
      expect(current_month_publication_date).to eq(Date.new(2021, 1, 8))
    end
  end

  describe '#previous_month_generation_date' do
    subject(:previous_month_generation_date) { described_class.new(base_date).previous_month_generation_date }

    let(:base_date) { Date.new(2021, 12, 1) }

    it 'is the third Monday of the previous month' do
      expect(previous_month_generation_date).to eq(Date.new(2021, 11, 15))
    end

    context 'when the base date is November' do
      let(:base_date) { Date.new(2021, 11, 1) }

      # We skip October see #current_generation_date
      it 'is the third Monday of September' do
        expect(previous_month_generation_date).to eq(Date.new(2021, 9, 20))
      end
    end
  end

  describe '#previous_month_publication_date' do
    subject(:previous_month_publication_date) { described_class.new(base_date).previous_month_publication_date }

    let(:base_date) { Date.new(2021, 1, 1) }

    it 'is a week after the third Monday of the previous month' do
      expect(previous_month_publication_date).to eq(Date.new(2020, 12, 28))
    end

    context 'when the base date is November' do
      let(:base_date) { Date.new(2021, 11, 1) }

      # We skip October see #current_generation_date
      it 'is a week after the third Monday of September' do
        expect(previous_month_publication_date).to eq(Date.new(2021, 9, 27))
      end
    end
  end

  describe '#next_month_generation_date' do
    subject(:next_month_generation_date) { described_class.new(base_date).next_month_generation_date }

    let(:base_date) { Date.new(2021, 1, 1) }

    it 'is the third Monday of the next month' do
      expect(next_month_generation_date).to eq(Date.new(2021, 2, 15))
    end

    context 'when the base date is September' do
      let(:base_date) { Date.new(2021, 9, 1) }

      # We skip October see #current_generation_date
      it 'is the third Monday of November' do
        expect(next_month_generation_date).to eq(Date.new(2021, 11, 15))
      end
    end
  end

  describe '#next_month_publication_date' do
    subject(:next_month_publication_date) { described_class.new(base_date).next_month_publication_date }

    let(:base_date) { Date.new(2021, 1, 1) }

    it 'is a week after the third Monday of the next month' do
      expect(next_month_publication_date).to eq(Date.new(2021, 2, 22))
    end

    context 'when the base date is September' do
      let(:base_date) { Date.new(2021, 9, 1) }

      # We skip October see #current_generation_date
      it 'is a week after the third Monday of November' do
        expect(next_month_publication_date).to eq(Date.new(2021, 11, 22))
      end
    end
  end

  describe '#current_publication_date' do
    subject(:current_publication_date) { described_class.new(base_date).current_publication_date }

    context 'beginning of September' do
      let(:base_date) { Date.new(2021, 9, 1) }

      it 'returns the publication for August' do
        expect(current_publication_date).to eq(Date.new(2021, 8, 23))
      end
    end

    context 'end of September' do
      let(:base_date) { Date.new(2021, 9, 30) }

      it 'returns the publication for September' do
        expect(current_publication_date).to eq(Date.new(2021, 9, 27))
      end
    end

    context 'beginning of October' do
      let(:base_date) { Date.new(2021, 10, 1) }

      it 'returns the publication for September' do
        expect(current_publication_date).to eq(Date.new(2021, 9, 27))
      end
    end

    context 'end of October' do
      let(:base_date) { Date.new(2021, 10, 30) }

      it 'returns the publication for September' do
        expect(current_publication_date).to eq(Date.new(2021, 9, 27))
      end
    end

    context 'beginning of November' do
      let(:base_date) { Date.new(2021, 11, 1) }

      it 'returns the publication for September' do
        expect(current_publication_date).to eq(Date.new(2021, 9, 27))
      end
    end

    context 'end of November' do
      let(:base_date) { Date.new(2021, 11, 30) }

      it 'returns the publication for November' do
        expect(current_publication_date).to eq(Date.new(2021, 11, 22))
      end
    end
  end
end
