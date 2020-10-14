require 'rails_helper'

RSpec.describe SendAdditionalReferenceChaseEmailToBothPartiesWorker do
  describe '#perform', sidekiq: true do
    FeatureFlag.deactivate(:decoupled_references)

    it 'sends a chaser email for application forms still awaiting reference feedback beyond the configured time limit' do
      application_form = create(
        :completed_application_form,
        application_choices: [create(:application_choice, status: :awaiting_references)],
      )
      reference_triggering_a_chase = create(:reference, :requested, application_form: application_form, requested_at: 29.days.ago)
      other_overdue_reference = create(:reference, :requested, application_form: application_form, requested_at: 29.days.ago)
      create(:reference, :complete, application_form: application_form, requested_at: 29.days.ago)

      described_class.new.perform

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 4
      expect(emails.first.subject).to match "#{reference_triggering_a_chase.name} has not responded yet"
      expect(emails.second.subject).to match "Will you not give #{application_form.full_name} a reference?"
      expect(emails.third.subject).to match "#{other_overdue_reference.name} has not responded yet"
      expect(emails.fourth.subject).to match "Will you not give #{application_form.full_name} a reference?"

      expect(application_form_id_of(emails.first)).to eq reference_triggering_a_chase.application_form.id
    end

    it 'persists a record of the application form being chased' do
      application_form = create(
        :completed_application_form,
        application_choices: [create(:application_choice, status: :awaiting_references)],
      )
      create(:reference, :requested, application_form: application_form, requested_at: 29.days.ago)

      described_class.new.perform

      expect(ChaserSent.follow_up_missing_references.length).to eq 1
      chaser = ChaserSent.follow_up_missing_references.first
      expect(chaser.chased).to eq application_form
    end

    it 'does not send chasers for application forms that are not submitted' do
      application_form = create(
        :application_form,
        application_choices: [create(:application_choice, status: :unsubmitted)],
      )
      create(:reference, :unsubmitted, requested_at: nil, application_form: application_form)

      described_class.new.perform

      expect(ChaserSent.follow_up_missing_references.length).to eq 0
      expect(ActionMailer::Base.deliveries.length).to eq 0
    end

    context 'when a chaser is already sent for an eligible application form' do
      let(:application_form) do
        create(
          :completed_application_form,
          application_choices: [create(:application_choice, status: :awaiting_references)],
        )
      end

      before { create(:chaser_sent, chased: application_form, chaser_type: :follow_up_missing_references) }

      it 'does not send another chaser' do
        create(:reference, :requested, application_form: application_form, requested_at: 29.days.ago)

        described_class.new.perform

        expect(ChaserSent.follow_up_missing_references.length).to eq 1
        expect(ActionMailer::Base.deliveries.length).to eq 0
      end
    end

  private

    def application_form_id_of(email)
      email.header_fields.find { |header| header.name == 'application-form-id' }.unparsed_value
    end
  end
end
