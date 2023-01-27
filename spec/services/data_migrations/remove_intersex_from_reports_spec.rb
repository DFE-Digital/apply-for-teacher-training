require 'rails_helper'

RSpec.describe DataMigrations::RemoveIntersexFromReports do
  let!(:report) { Publications::MonthlyStatistics::MonthlyStatisticsReport.create!(month:, statistics:) }

  before { advance_time }

  context 'when a report has intersex data' do
    let(:statistics) do
      {
        'by_sex' =>
          { 'rows' =>
            [{ 'Sex' => 'Female', 'Recruited' => 6, 'Conditions pending' => 5, 'Deferred' => 13, 'Received an offer' => 44, 'Awaiting provider decisions' => 72, 'Unsuccessful' => 44, 'Total' => 184 },
             { 'Sex' => 'Male', 'Recruited' => 6, 'Conditions pending' => 1, 'Deferred' => 7, 'Received an offer' => 47, 'Awaiting provider decisions' => 91, 'Unsuccessful' => 29, 'Total' => 181 },
             { 'Sex' => 'Intersex', 'Recruited' => 0, 'Conditions pending' => 0, 'Deferred' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
             { 'Sex' => 'Other', 'Recruited' => 10, 'Conditions pending' => 4, 'Deferred' => 8, 'Received an offer' => 62, 'Awaiting provider decisions' => 72, 'Unsuccessful' => 38, 'Total' => 194 },
             { 'Sex' => 'Prefer not to say', 'Recruited' => 10, 'Conditions pending' => 7, 'Deferred' => 6, 'Received an offer' => 51, 'Awaiting provider decisions' => 67, 'Unsuccessful' => 30, 'Total' => 171 }],
            'column_totals' => [32, 17, 34, 204, 302, 141, 730] },
      }
    end

    context 'and the report is on or after October 2022' do
      let(:month) { '2022-10' }

      # No need to change the column totals,
      # I've checked that they're all 0 for intersex
      # in the production database for these months.
      it 'removes the intersex data' do
        expect { described_class.new.change }.to(change { report.reload.updated_at })
        expect(report.statistics.dig('by_sex', 'rows').find { |row| row['Sex'] == 'Intersex' }).to be_nil
      end
    end

    context 'and the report is before October 2022' do
      let(:month) { '2022-09' }

      it 'does not remove the intersex data' do
        expect { described_class.new.change }.not_to(change { report.reload.updated_at })
        expect(report.statistics.dig('by_sex', 'rows').find { |row| row['Sex'] == 'Intersex' }).not_to be_nil
      end
    end
  end

  context 'when a report does not have intersex data' do
    let(:statistics) do
      {
        'by_sex' =>
          { 'rows' =>
            [{ 'Sex' => 'Female', 'Recruited' => 6, 'Conditions pending' => 5, 'Deferred' => 13, 'Received an offer' => 44, 'Awaiting provider decisions' => 72, 'Unsuccessful' => 44, 'Total' => 184 },
             { 'Sex' => 'Male', 'Recruited' => 6, 'Conditions pending' => 1, 'Deferred' => 7, 'Received an offer' => 47, 'Awaiting provider decisions' => 91, 'Unsuccessful' => 29, 'Total' => 181 },
             { 'Sex' => 'Other', 'Recruited' => 10, 'Conditions pending' => 4, 'Deferred' => 8, 'Received an offer' => 62, 'Awaiting provider decisions' => 72, 'Unsuccessful' => 38, 'Total' => 194 },
             { 'Sex' => 'Prefer not to say', 'Recruited' => 10, 'Conditions pending' => 7, 'Deferred' => 6, 'Received an offer' => 51, 'Awaiting provider decisions' => 67, 'Unsuccessful' => 30, 'Total' => 171 }],
            'column_totals' => [32, 17, 34, 204, 302, 141, 730] },
      }
    end

    context 'and the report is on or after October 2022' do
      let(:month) { '2022-10' }

      it 'does not update the record' do
        expect { described_class.new.change }.not_to(change { report.reload.updated_at })
      end
    end

    context 'and the report is before October 2022' do
      let(:month) { '2022-09' }

      it 'does not update the record' do
        expect { described_class.new.change }.not_to(change { report.reload.updated_at })
      end
    end
  end
end
