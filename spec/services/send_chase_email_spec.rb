require 'rails_helper'

RSpec.describe SendChaseEmail do
  describe '#perform' do
    before do
      allow(RefereeMailer).to receive(:reference_request_chaser_email)
    end

    it 'updates the application choices status to awaiting_references_and_chased' do
      application_form = create(:application_form)
      reference = create(:reference, application_form: application_form)
      application_choice = create(:application_choice, application_form: application_form, status: 'awaiting_references')

      described_class.new.perform(reference: reference)

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference)
      expect(application_choice.reload.status).to eq('awaiting_references_and_chased')
    end
  end
end
