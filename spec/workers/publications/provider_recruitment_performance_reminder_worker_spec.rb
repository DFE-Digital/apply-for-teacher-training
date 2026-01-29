require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReminderWorker do
  let(:cycle_week) { RecruitmentCycleTimetable.current_cycle_week.pred }
  let(:recruitment_cycle_year) { RecruitmentCycleTimetable.current_year }
  let(:provider) { create(:provider, :no_users) }
  let!(:provider_user) { create(:provider_user, providers: [provider]) }
  let(:national_recruitment_performance_report) do
    create(:national_recruitment_performance_report, cycle_week:, recruitment_cycle_year:)
  end
  let(:provider_recruitment_performance_report) do
    create(:provider_recruitment_performance_report, provider:, cycle_week:, recruitment_cycle_year:)
  end

  describe '#perform' do
    context 'when no national recruitment performance report exists' do
      it 'returns nil' do
        expect(described_class.new.perform).to be_nil
      end
    end

    context 'when no provider recruitment performance report exists for the given provider' do
      before do
        national_recruitment_performance_report
        create(:provider_recruitment_performance_report, cycle_week:, recruitment_cycle_year:)
        allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_call_original
      end

      it 'does not sends an email to the provider user' do
        described_class.new.perform
        expect(ProviderMailer).not_to have_received(:recruitment_performance_report_reminder).with(provider_user)
      end
    end

    context 'when a national recruitment performance report exists' do
      before do
        national_recruitment_performance_report
        provider_recruitment_performance_report
        allow(ProviderMailer).to receive(:recruitment_performance_report_reminder).and_call_original
      end

      it 'sends an email to the provider user' do
        described_class.new.perform
        expect(ProviderMailer).to have_received(:recruitment_performance_report_reminder).with(provider_user)
      end
    end
  end
end
