require 'rails_helper'

RSpec.describe RejectAwaitingReferencesCourseChoicesWorker do
  describe '#perform' do
    it 'calls the appropriate services' do
      application_choice = create(:application_choice, :awaiting_references)
      allow(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to receive(:call).and_return([application_choice.application_form])
      allow(CandidateMailer).to receive(:application_on_pause).and_call_original
      RejectAwaitingReferencesCourseChoicesWorker.new.perform

      expect(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to have_received(:call)
      expect(CandidateMailer).to have_received(:application_on_pause).with(application_choice.application_form)
    end
  end
end
