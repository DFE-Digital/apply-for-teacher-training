require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersWorker do
  describe '#perform' do
    context 'is before the date for sending the reminder', time: reject_by_default_reminder_run_date - 1.day do
      it 'does not enqueue the batch worker' do
        application_choices = create(:application_choice, :awaiting_provider_decision)
        create(:provider_permissions, provider: application_choices.provider)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'is after the date for sending the reminder', time: reject_by_default_reminder_run_date + 1.day do
      it 'does not enqueue the batch worker' do
        application_choices = create(:application_choice, :awaiting_provider_decision)
        create(:provider_permissions, provider: application_choices.provider)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'it is on the reminder date', time: reject_by_default_reminder_run_date do
      it 'calls batch worker with application choices' do
        inactive_application = create(:application_choice, :inactive)
        interview_application = create(:application_choice, :interviewing)
        awaiting_application = create(:application_choice, :awaiting_provider_decision)

        # These two application choices should not be included
        create(:application_choice, :rejected)
        create(:application_choice, :unsubmitted)

        allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
        described_class.new.perform

        expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker)
          .to have_received(:perform_at).with(kind_of(Time), [
            inactive_application.provider.id,
            interview_application.provider.id,
            awaiting_application.provider.id,
          ])
      end
    end
  end
end
