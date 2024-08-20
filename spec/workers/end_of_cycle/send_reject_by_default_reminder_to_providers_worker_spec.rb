require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersWorker do
  describe '#relation' do
    it 'includes providers who have rejectable choices only' do
      inactive_application = create(:application_choice, :inactive)
      interview_application = create(:application_choice, :interviewing)
      awaiting_application = create(:application_choice, :awaiting_provider_decision)

      create(:application_choice, :rejected)

      results = described_class.new.relation

      expect(results)
        .to contain_exactly(
          inactive_application.provider,
          interview_application.provider,
          awaiting_application.provider,
        )
    end
  end

  describe '#perform' do
    context 'is before the date for sending the reminder', time: reject_by_default_reminder_run_date - 1.day do
      it 'does not send any emails' do
        application_choices = create(:application_choice, :awaiting_provider_decision)
        create(:provider_permissions, provider: application_choices.provider)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'is after the date for sending the reminder', time: reject_by_default_reminder_run_date + 1.day do
      it 'does not send any emails' do
        application_choices = create(:application_choice, :awaiting_provider_decision)
        create(:provider_permissions, provider: application_choices.provider)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'it is on the reminder date', time: reject_by_default_reminder_run_date do
      it 'sends emails and creates chaser sent record' do
        application_choices = create(:application_choice, :awaiting_provider_decision)
        create(:provider_permissions, provider: application_choices.provider)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to have_received(:perform_at)
      end
    end
  end
end
