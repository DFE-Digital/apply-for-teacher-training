require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersWorker do
  describe '#perform' do
    context 'is before the date for sending the reminder' do
      it 'does not enqueue the batch worker' do
        travel_temporarily_to(email_send_date - 1.day) do
          application_choices = create(:application_choice, :awaiting_provider_decision)
          create(:provider_permissions, provider: application_choices.provider)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform
          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
        end
      end
    end

    context 'is after the date for sending the reminder' do
      it 'does not enqueue the batch worker' do
        travel_temporarily_to(email_send_date + 1.day) do
          application_choices = create(:application_choice, :awaiting_provider_decision)
          create(:provider_permissions, provider: application_choices.provider)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform
          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
        end
      end
    end

    context 'it is on the reminder date' do
      it 'calls batch worker with application choices' do
        travel_temporarily_to(email_send_date) do
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

  def email_send_date
    EndOfCycle::ProviderEmailTimetabler.new.reject_by_default_reminder_provider_date
  end
end
