require 'rails_helper'

RSpec.describe Publications::V1::MonthlyStatisticsPresenter do
  let(:statistics) { {} }
  let(:report) do
    instance_double(
      Publications::MonthlyStatistics::MonthlyStatisticsReport,
      statistics:,
      created_at: Date.new(2021, 11, 23),
      month: '2021-11',
      generation_date: Date.new(2021, 11, 22),
      publication_date: Date.new(2021, 11, 29),
    )
  end

  subject(:presenter) { described_class.new(report) }

  describe '#first_published_cycle?' do
    context 'when current cycle' do
      before do
        allow(report).to receive(:generation_date).and_return(
          current_timetable.apply_opens_at.to_date,
        )
      end

      it 'returns false' do
        expect(presenter.first_published_cycle?).to be false
      end
    end

    context 'when previous cycle' do
      before do
        allow(report).to receive(:generation_date).and_return(Date.new(2022, 8, 22))
      end

      it 'returns true' do
        expect(presenter.first_published_cycle?).to be true
      end
    end
  end

  describe '#next_cycle_name' do
    it 'returns the years for the start and end of the next academic year' do
      expect(presenter.next_cycle_name).to eq('2022 to 2023')
    end
  end

  describe '#current_cycle_verbose_name' do
    it 'returns the months and years for the start and end of the current recruitment cycle' do
      expect(presenter.current_cycle_verbose_name).to eq('October 2021 to September 2022')
    end
  end

  describe '#previous_cycle_verbose_name' do
    it 'returns the months and years for the start and end of the last recruitment cycle' do
      expect(presenter.previous_cycle_verbose_name).to eq('October 2020 to September 2021')
    end
  end

  describe '#current_year' do
    it 'returns the year for the current recruitment cycle' do
      expect(presenter.current_year).to eq(2022)
    end
  end

  describe '#previous_year' do
    it 'returns the year for the last recruitment cycle' do
      expect(presenter.previous_year).to eq(2021)
    end
  end

  describe '#deferred_applications_count' do
    context 'when no data is available' do
      it 'returns 0' do
        expect(presenter.deferred_applications_count).to eq(0)
      end
    end

    context 'when a count is available' do
      let(:statistics) { { deferred_applications_count: 37 }.with_indifferent_access }

      it 'returns the correct count' do
        expect(presenter.deferred_applications_count).to eq(37)
      end
    end
  end

  describe '#current_reporting_period' do
    it 'returns the correct dates per the Timetable' do
      expect(presenter.current_reporting_period).to eq '12 October 2021 to 22 November 2021'
    end
  end

  describe '#next_publication_date' do
    context 'when there is a draft report' do
      it 'returns the publication date of that report' do
        publication_date = 1.day.from_now
        create(:monthly_statistics_report, :v2, publication_date:)
        expect(presenter.next_publication_date.to_date).to eq publication_date.to_date
      end
    end

    context 'when there is no draft report' do
      it 'returns the projected publication date' do
        travel_temporarily_to(Date.new(2021, 12, 21)) do
          expect(presenter.next_publication_date).to eq(Date.new(2021, 12, 27))
        end
      end
    end
  end
end
