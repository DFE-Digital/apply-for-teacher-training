require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesBatchWorker, :sidekiq do
  describe '#perform' do
    let(:candidate) { create(:candidate) }

    let(:application_form) do
      create(
        :application_form,
        candidate:,
        application_choices: [create(:application_choice, :application_not_sent)],
        recruitment_cycle_year: current_year,
      )
    end

    context 'for each eoc reminder type' do
      %i[eoc_first_deadline_reminder eoc_second_deadline_reminder].each do |chaser_type|
        it 'sends emails to the given candidates' do
          described_class.new.perform(application_form.id, chaser_type)

          expect(email_for_candidate(candidate)).to be_present
        end

        it 'creates ChaserSent for the given candidates' do
          described_class.new.perform(application_form.id, chaser_type)

          expect(candidate.current_application.chasers_sent.pluck(:chaser_type)).to eq([chaser_type.to_s])
        end

        it 'does nothing if the email was already sent', time: after_apply_deadline do
          candidate.current_application.chasers_sent.create(chaser_type:)

          described_class.new.perform(candidate.id, chaser_type)

          expect(email_for_candidate(candidate)).not_to be_present
        end
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
