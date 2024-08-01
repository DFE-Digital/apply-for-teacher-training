require 'rails_helper'

RSpec.describe DataMigrations::BackfillWeek42PerformanceReportData do
  it 'destroys existing week 42 data' do
    national_report_week_43 = create(:national_recruitment_performance_report, cycle_week: 43)
    national_report_week_42 = create(:national_recruitment_performance_report, cycle_week: 42)

    provider_report_week_43 = create(:provider_recruitment_performance_report, cycle_week: 43)
    provider_report_week_42 = create(:provider_recruitment_performance_report, cycle_week: 42)

    described_class.new.change

    expect(national_report_week_43.reload.present?).to be true
    expect(provider_report_week_43.reload.present?).to be true

    expect { national_report_week_42.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { provider_report_week_42.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'creates new data' do
    let(:provider_worker) { Publications::ProviderRecruitmentPerformanceReportWorker }
    let(:national_worker) { Publications::NationalRecruitmentPerformanceReportWorker }
    let(:provider) { create(:provider) }

    before do
      allow(national_worker).to receive(:perform_async)
      allow(provider_worker).to receive(:perform_async)
      provider
      allow(ProvidersForRecruitmentPerformanceReportQuery).to receive(:call).with(cycle_week: 42).and_return(Provider)
    end

    it 'enqueues jobs for creating new data for week 42' do
      described_class.new.change

      expect(provider_worker).to have_received(:perform_async).with(provider.id, 42)
      expect(national_worker).to have_received(:perform_async).with(42)
    end
  end
end
