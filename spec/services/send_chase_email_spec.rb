require 'rails_helper'

RSpec.describe SendChaseEmail do
  describe '#perform' do
    before do
      allow(RefereeMailer).to receive(:reference_request_chaser_email)
    end

    it 'sends a chaser email and creates a new ChasedEmail associated to the reference' do
      application_form = create(:application_form)
      reference = create(:reference, application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_references')

      described_class.new.perform(reference: reference)

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference)
      expect(reference.chasers_sent.referee_mailer_reference_request_chaser_email.count).to eq(1)
    end
  end
end
