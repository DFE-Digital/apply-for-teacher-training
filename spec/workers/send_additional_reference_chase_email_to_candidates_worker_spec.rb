require 'rails_helper'

RSpec.describe SendAdditionalReferenceChaseEmailToCandidatesWorker do
  describe '#perform', sidekiq: true do
    it 'sends a chaser email for application forms still awaiting reference feedback beyond the configured time limit' do
      reference_triggering_a_chase = create(:reference, :requested, requested_at: 29.days.ago)
      create(:reference, :requested, requested_at: 27.days.ago)
      create(:reference, :complete, requested_at: 29.days.ago)

      described_class.new.perform

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.subject).to match %r{Get your references as soon as possible}
      expect(application_form_id_of(emails.first)).to eq reference_triggering_a_chase.application_form.id
    end

    it 'sends only one chaser email per application form' do
      application_form = create(:completed_application_form)
      create(:reference, :requested, requested_at: 29.days.ago, application_form: application_form)
      create(:reference, :requested, requested_at: 29.days.ago, application_form: application_form)

      described_class.new.perform

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.subject).to match %r{Get your references as soon as possible}
    end

    it 'persists a record of the application form being chased' do
      reference_triggering_a_chase = create(:reference, :requested, requested_at: 29.days.ago)

      described_class.new.perform

      expect(ChaserSent.follow_up_missing_references.count).to eq 1
      chaser = ChaserSent.follow_up_missing_references.first
      expect(chaser.chased).to eq reference_triggering_a_chase.application_form
    end

    context 'when a chaser is already sent for an eligible application form' do
      it 'does not send another chaser' do
        reference = create(:reference, :requested, requested_at: 29.days.ago)
        create(:chaser_sent, chased: reference.application_form, chaser_type: :follow_up_missing_references)

        described_class.new.perform

        expect(ChaserSent.follow_up_missing_references.count).to eq 1
        expect(ActionMailer::Base.deliveries.length).to eq 0
      end
    end

  private

    def application_form_id_of(email)
      email.header_fields.find { |header| header.name == 'application-form-id' }.unparsed_value
    end
  end
end
