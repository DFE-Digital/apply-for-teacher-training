require 'rails_helper'

RSpec.describe SendChaseEmailToRefereeAndCandidate do
  describe '#call' do
    it 'sends a chaser email to the candidate and referee' do
      application_form = create(:completed_application_form)
      reference = create(:reference, application_form: application_form)
      create(:application_choice, application_form: application_form, status: 'awaiting_references')

      described_class.call(application_form: application_form, reference: reference)

      expect(reference.chasers_sent.reference_request.count).to eq(1)
    end
  end
end
