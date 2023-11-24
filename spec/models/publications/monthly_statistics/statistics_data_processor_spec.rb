require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::StatisticsDataProcessor do
  describe '#violates_gdpr?' do
    subject(:violates_gdpr?) { described_class.new(status_data:).violates_gdpr? }

    context 'when violates GDPR in headline statistics' do
      let(:status_data) do
        {
          this_cycle: 1,
          last_cycle: 10,
        }
      end

      it 'returns true' do
        expect(violates_gdpr?).to be true
      end
    end

    context 'when violates GDPR in other sections' do
      let(:status_data) do
        [
          {
            title: 'London',
            this_cycle: 0,
            last_cycle: 10,
          },
          {
            title: 'Other',
            this_cycle: 1,
            last_cycle: 10,
          },
        ]
      end

      it 'returns true' do
        expect(violates_gdpr?).to be true
      end
    end

    context 'when does not violates GDPR in headline statistics' do
      let(:status_data) do
        {
          this_cycle: 4,
          last_cycle: 10,
        }
      end

      it 'returns false' do
        expect(violates_gdpr?).to be false
      end
    end

    context 'when does not violates GDPR in other sections' do
      let(:status_data) do
        [
          {
            title: 'London',
            this_cycle: 3,
            last_cycle: 10,
          },
          {
            title: 'Other',
            this_cycle: 1,
            last_cycle: 10,
          },
        ]
      end

      it 'returns false' do
        expect(violates_gdpr?).to be false
      end
    end
  end
end
