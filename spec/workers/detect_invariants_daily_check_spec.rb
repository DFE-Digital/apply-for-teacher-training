require 'rails_helper'

RSpec.describe DetectInvariantsDailyCheck do
  describe '#perform' do
    context 'when checking the monthly statistics report' do
      let(:message) { 'The monthly statistics report has not been generated for June' }
      let(:exception) { described_class::MonthlyStatisticsReportHasNotRun.new(message) }

      before do
        allow(HostingEnvironment).to receive(:production?).and_return true
        allow(Sentry).to receive(:capture_exception).with(an_instance_of(described_class::MonthlyStatisticsReportHasNotRun))
      end

      context 'when it has been generated' do
        it 'does not send an alert' do
          travel_temporarily_to(Date.new(2023, 6, 26)) do
            create(
              :monthly_statistics_report,
              :v1,
              generation_date: Date.new(2023, 6, 19),
            )

            described_class.new.perform

            expect(Sentry).not_to have_received(:capture_exception).with(exception)
          end
        end
      end

      context 'when it has not been generated' do
        it 'sends an alert' do
          travel_temporarily_to(Date.new(2023, 6, 26)) do
            create(
              :monthly_statistics_report,
              :v1,
              generation_date: Date.new(2023, 5, 15),
            )

            described_class.new.perform

            expect(Sentry).to have_received(:capture_exception).with(exception)
          end
        end
      end

      context 'when it is before reports are generated' do
        it 'does not send an alert' do
          first_generation_date = Publications::MonthlyStatistics::Timetable.new.schedules.first.generation_date
          travel_temporarily_to(first_generation_date - 1.day) do
            described_class.new.perform

            expect(Sentry).not_to have_received(:capture_exception).with(exception)
          end
        end
      end
    end
  end
end
