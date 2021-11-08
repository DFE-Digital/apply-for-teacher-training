require 'rails_helper'

RSpec.describe UpdateMonthlyStatisticsReport, sidekiq: true do
  describe '#perform' do
    context 'it is the beginning of the month' do
      it 'generates the monthly stats' do
        expect(MonthlyStatisticsReport.count).to eq(0)

        described_class.new.perform

        expect(MonthlyStatisticsReport.count).to eq(1)
      end
    end
  end
end
