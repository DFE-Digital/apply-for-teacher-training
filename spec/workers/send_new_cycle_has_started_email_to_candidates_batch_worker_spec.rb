require 'rails_helper'

RSpec.describe SendNewCycleHasStartedEmailToCandidatesBatchWorker, :sidekiq do
  describe '#perform' do
    before do
      allow(SendNewCycleHasStartedEmailToCandidate)
        .to receive(:call).with(application_form: kind_of(ApplicationForm)).twice
    end

    it 'sends emails to the given candidates' do
      application_forms = create_list(:application_form, 2)
      candidate_ids = application_forms.pluck(:candidate_id)

      described_class.perform_now(candidate_ids)
      expect(SendNewCycleHasStartedEmailToCandidate)
        .to have_received(:call).with(application_form: application_forms[0])
      expect(SendNewCycleHasStartedEmailToCandidate)
        .to have_received(:call).with(application_form: application_forms[1])
    end
  end
end
