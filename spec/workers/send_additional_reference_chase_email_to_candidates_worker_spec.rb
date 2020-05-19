require 'rails_helper'

RSpec.describe SendAdditionalReferenceChaseEmailToCandidatesWorker do
  describe '#perform', sidekiq: true do
    it 'sends a chaser email for references still awaiting feedback beyond the configured time limit' do
      reference_to_chase = create(:reference, :requested, requested_at: 29.days.ago)
      create(:reference, :requested, requested_at: 27.days.ago)
      create(:reference, :complete, requested_at: 29.days.ago)

      described_class.new.perform

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.subject).to match %r{Get your references as soon as possible}
      expect(application_form_id_of(emails.first)).to eq reference_to_chase.application_form.id
    end

    it 'persists a record of the chaser being sent' do
      reference_to_chase = create(:reference, :requested, requested_at: 29.days.ago)

      described_class.new.perform

      expect(ChaserSent.additional_reference_request.count).to eq 1
      chaser = ChaserSent.additional_reference_request.first
      expect(chaser.chased).to eq reference_to_chase
    end

    context 'when a chaser is already sent for an eligible reference' do
      it 'does not send another chaser' do
        reference = create(:reference, :requested, requested_at: 29.days.ago)
        create(:chaser_sent, chased: reference, chaser_type: :additional_reference_request)

        described_class.new.perform

        expect(ChaserSent.additional_reference_request.count).to eq 1
        expect(ActionMailer::Base.deliveries.length).to eq 0
      end
    end

  private

    def application_form_id_of(email)
      email.header_fields.find { |header| header.name == 'application-form-id' }.unparsed_value
    end
  end
end
