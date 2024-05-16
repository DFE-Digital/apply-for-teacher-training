require 'rails_helper'

RSpec.describe Publications::RecruitmentPerformanceReportScheduler do
  let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
  let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
  let(:provider) { create(:provider) }
  let(:cycle_week) { CycleTimetable.current_cycle_week.pred }

  context 'provider report is generated for appropriate providers' do
    before do
      allow(provider_worker).to receive(:perform_async)
      provider
      allow(ProvidersForRecruitmentPerformanceReportQuery).to receive(:call).with(cycle_week:).and_return(Provider)
    end

    it 'creates a report for a provider who received an application last week' do
      described_class.new.call

      expect(provider_worker).to have_received(:perform_async).with(provider.id, cycle_week)
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 2 }

      it 'creates a report for a provider who received an application before cycle_week' do
        described_class.new(cycle_week:).call

        expect(provider_worker).to have_received(:perform_async).with(provider.id, cycle_week)
      end
    end
  end

  context 'national report is generated' do
    before do
      allow(national_worker).to receive(:perform_async)
    end

    it 'creates a National report' do
      described_class.new.call

      expect(national_worker).to have_received(:perform_async).with(cycle_week)
    end

    it 'does not create a National report worker when a report already exists' do
      Publications::NationalRecruitmentPerformanceReport.create!(
        statistics: {},
        publication_date: Time.zone.today,
        cycle_week:,
      )

      described_class.new.call

      expect(national_worker).not_to have_received(:perform_async).with(cycle_week)
    end

    context 'explicit cycle_week is passed' do
      let(:cycle_week) { 2 }

      it 'creates a national report for the cycle_week value' do
        described_class.new(cycle_week:).call

        expect(national_worker).to have_received(:perform_async).with(cycle_week)
      end
    end
  end
end
