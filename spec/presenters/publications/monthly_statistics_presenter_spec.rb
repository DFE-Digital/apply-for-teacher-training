require 'rails_helper'

RSpec.describe Publications::MonthlyStatisticsPresenter do
  around do |example|
    Timecop.freeze(Date.new(2021, 12, 1)) { example.run }
  end

  let(:report) { double }
  subject(:presenter) { described_class.new(report) }

  describe '#next_cycle_name' do
    it 'returns the years for the start and end of the next academic year' do
      expect(subject.next_cycle_name).to eq('2022 to 2023')
    end
  end

  describe '#current_cycle_verbose_name' do
    it 'returns the months and years for the start and end of the current recruitment cycle' do
      expect(subject.current_cycle_verbose_name).to eq('October 2021 to September 2022')
    end
  end

  describe '#current_year' do
    it 'returns the year for the current recruitment cycle' do
      expect(subject.current_year).to eq(2022)
    end
  end
end
