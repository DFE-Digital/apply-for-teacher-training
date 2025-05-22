require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::MonthlyStatisticsReport do
  before { TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 23)) }

  describe 'validations' do
    it { is_expected.to validate_presence_of :statistics }
    it { is_expected.to validate_presence_of :generation_date }
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :month }
  end

  describe 'scopes' do
    describe '.published' do
      it 'returns only reports with publication dates in the past' do
        create(
          :monthly_statistics_report,
          :v2,
          publication_date: 1.day.from_now,
          generation_date: 1.day.ago,
        )

        published_report = create(
          :monthly_statistics_report,
          :v2,
          publication_date: 1.day.ago,
          generation_date: 1.day.ago,
        )

        expect(described_class.published).to eq [published_report]
      end
    end
  end

  describe '#draft?' do
    context 'when report is generated but not published' do
      subject(:report) do
        create(
          :monthly_statistics_report,
          :v2,
          generation_date: Time.zone.local(2023, 11, 20),
          publication_date: Time.zone.local(2023, 11, 27),
        )
      end

      it 'returns true' do
        expect(report.draft?).to be true
      end
    end

    context 'when report is generated and published' do
      subject(:report) do
        create(
          :monthly_statistics_report,
          :v2,
          generation_date: Time.zone.local(2023, 9, 20),
          publication_date: Time.zone.local(2023, 9, 27),
        )
      end

      it 'returns false' do
        expect(report.draft?).to be false
      end
    end
  end

  describe '#v2?' do
    context 'when report is generated in the second version' do
      subject(:report) { create(:monthly_statistics_report, :v2) }

      it 'returns true' do
        expect(report.v2?).to be true
      end
    end

    context 'when report is generated in the first version' do
      subject(:report) { create(:monthly_statistics_report, :v1) }

      it 'returns false' do
        expect(report.v2?).to be false
      end
    end
  end

  describe '#current_period' do
    upcoming_publication_date = Date.new(2021, 12, 22)
    let!(:current_report) do
      create(:monthly_statistics_report, :v1, month: '2021-12', publication_date: upcoming_publication_date)
    end
    let!(:previous_report) do
      create(:monthly_statistics_report, :v1, month: '2021-11', publication_date: upcoming_publication_date - 1.month)
    end

    context 'when today is before the publishing date in the current month' do
      it 'returns the previous report' do
        travel_temporarily_to(upcoming_publication_date - 1.day) do
          expect(described_class.current_period).to eq(previous_report)
        end
      end
    end

    context 'when today is on or after the publishing date in the current month' do
      it 'returns the previous report' do
        travel_temporarily_to(Time.zone.local(2021, 12, 27, 0, 0, 1)) do
          expect(described_class.current_period).to eq(current_report)
        end
      end
    end
  end

  describe '.current_published_report_at' do
    let!(:report) do
      create(
        :monthly_statistics_report,
        :v2,
        generation_date: Time.zone.local(2023, 11, 20),
        publication_date: Time.zone.local(2023, 11, 23),
        month: '2023-11',
      )
    end

    context 'when requesting for existing report' do
      it 'returns report for the given month' do
        expect(described_class.current_published_report_at(Date.new(2023, 11, 1))).to eq(report)
      end
    end

    context 'when requesting for report that does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.current_published_report_at(Date.new(2023, 10, 1))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.report_for_latest_in_cycle' do
    before { TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 27)) }

    let!(:latest_report_for_current_cycle) do
      create(
        :monthly_statistics_report,
        :v2,
        generation_date: Time.zone.local(2023, 11, 20),
        publication_date: Time.zone.local(2023, 11, 27),
        month: '2023-11',
      )
    end

    let!(:latest_report_for_old_cycle) do
      create(
        :monthly_statistics_report,
        :v1,
        generation_date: Time.zone.local(2023, 9, 18),
        publication_date: Time.zone.local(2023, 9, 25),
        month: '2023-09',
      )
    end

    context 'when current cycle' do
      it 'returns latest report in the cycle' do
        expect(described_class.report_for_latest_in_cycle(2024)).to eq(latest_report_for_current_cycle)
      end
    end

    context 'when old cycle' do
      it 'returns latest report in the cycle' do
        expect(described_class.report_for_latest_in_cycle(2023)).to eq(latest_report_for_old_cycle)
      end
    end

    context 'when cycle not included in cycle timetable' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.report_for_latest_in_cycle(2000)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when future cycle' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.report_for_latest_in_cycle(2025)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
