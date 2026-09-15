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

      context 'when it has not been generated on the generation_date but has been generated for the month' do
        it 'does not sends an alert' do
          travel_temporarily_to(Date.new(2023, 6, 26)) do
            create(
              :monthly_statistics_report,
              :v1,
              generation_date: Date.new(2023, 6, 16),
              month: '2023-06',
            )

            described_class.new.perform

            # expect(Sentry).to have_received(:capture_exception).with(exception)
            expect(Sentry).not_to have_received(:capture_exception).with(exception)
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

    context 'when checking for unconfirmed vendors' do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return true
        allow(Sentry).to receive(:capture_exception)
      end

      it 'detects unconfirmed vendors' do
        unconfirmed_vendor = create(:vendor, name: 'unconfirmed', status: :unconfirmed)
        create(:vendor, status: :unconfirmed) # in_house vendor

        described_class.new.perform

        expect(Sentry).to have_received(:capture_exception).with(
          described_class::UnconfirmedVendorsError.new(
            "The vendors with ids #{[unconfirmed_vendor.id]} have been created by providers, we need to confirm if they are real vendors",
          ),
        )
      end

      it 'doesn’t alert when all vendors are confirmed' do
        create(:vendor, name: 'confirmed_vendor', status: :confirmed)

        described_class.new.perform

        expect(Sentry).not_to have_received(:capture_exception)
      end
    end
  end
end
