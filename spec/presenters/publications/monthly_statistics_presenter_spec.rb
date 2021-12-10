require 'rails_helper'

RSpec.describe Publications::MonthlyStatisticsPresenter do
  around do |example|
    Timecop.freeze(Date.new(2021, 12, 1)) { example.run }
  end

  let(:report) do
    instance_double(
      Publications::MonthlyStatistics::MonthlyStatisticsReport,
      created_at: Date.new(2021, 11, 23),
    )
  end

  subject(:presenter) { described_class.new(report) }

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

  describe '#current_reporting_period' do
    it 'returns the date range for the current reporting period' do
      expect(presenter.current_reporting_period).to eq('12 October 2021 to 23 November 2021')
    end
  end
end
