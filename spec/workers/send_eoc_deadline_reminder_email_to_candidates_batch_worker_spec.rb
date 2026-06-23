require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesBatchWorker do
  describe '#perform' do
    let(:application_form) do
      create(
        :application_form,
        application_choices: [build(:application_choice, :application_not_sent)],
        recruitment_cycle_year: current_year,
      )
    end

    context 'for each eoc reminder type' do
      %i[eoc_first_deadline_reminder eoc_second_deadline_reminder].each do |chaser_type|
        it 'enqueues mail delivery jobs for the given candidates' do
          clear_enqueued_jobs

          expect {
            described_class.new.perform(application_form.id, chaser_type)
          }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end

        it 'creates ChaserSent for the given candidates' do
          described_class.new.perform(application_form.id, chaser_type)

          expect(application_form.chasers_sent.pluck(:chaser_type)).to eq([chaser_type.to_s])
        end

        it 'does nothing if the email was already sent', time: after_apply_deadline do
          clear_enqueued_jobs

          application_form.chasers_sent.create(chaser_type:)

          expect { described_class.new.perform(application_form.id, chaser_type) }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end
  end
end
