require 'rails_helper'

RSpec.describe SendFindHasOpenedEmailToCandidatesBatchWorker do
  describe '#perform' do
    before do
      allow(SendFindHasOpenedEmailToCandidate).to receive(:call).with(application_form: kind_of(ApplicationForm)).thrice
    end

    it 'calls SendFindHasOpenedEmailToCandidate with given candidate_ids' do
      application_forms = create_list(:application_form, 3)
      candidate_ids = application_forms.pluck(:candidate_id)

      described_class.perform_now(candidate_ids)

      expect(SendFindHasOpenedEmailToCandidate)
        .to have_received(:call).with(application_form: application_forms[0])
      expect(SendFindHasOpenedEmailToCandidate)
        .to have_received(:call).with(application_form: application_forms[1])
      expect(SendFindHasOpenedEmailToCandidate)
        .to have_received(:call).with(application_form: application_forms[2])
    end
  end
end
