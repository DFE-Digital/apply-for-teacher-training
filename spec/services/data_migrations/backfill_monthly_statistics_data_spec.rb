require 'rails_helper'

RSpec.describe DataMigrations::BackfillMonthlyStatisticsData do
  describe 'monthly statistics report data' do
    context 'when month does not exist' do
      it 'update the month for a future report' do
        Timecop.freeze(Date.new(2022, 1, 21)) do
          report_with_unset_month = Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: nil)
          report_with_set_month = Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: '2021-07')

          expect { described_class.new.change }.to change { report_with_unset_month.reload.month }.to('2022-01')
          expect { described_class.new.change }.not_to(change { report_with_set_month.reload.month })
        end
      end
    end

    context 'when report is created in following month' do
      it 'updates the month to the previous month' do
        Timecop.freeze(Date.new(2021, 12, 11)) do
          report_with_unset_month = Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: nil)

          expect { described_class.new.change }.to change { report_with_unset_month.reload.month }.to('2021-11')
        end
      end
    end

    context 'when report is created in same month' do
      it 'updates to same month' do
        Timecop.freeze(Date.new(2021, 12, 21)) do
          report_with_unset_month = Publications::MonthlyStatistics::MonthlyStatisticsReport.create(month: nil)

          expect { described_class.new.change }.to change { report_with_unset_month.reload.month }.to('2021-12')
        end
      end
    end
  end
end
