require 'rails_helper'

RSpec.describe RejectAwaitingReferencesCourseChoicesWorker do
  describe '#perform' do
    it 'calls the appropriate services' do
      application_choice = create(:application_choice, :awaiting_references)
      application_form = application_choice.application_form
      application_choice_withdrawn = create(:application_choice, :withdrawn, application_form: application_form)

      allow(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to receive(:call).and_return([application_choice.application_form])
      allow(CandidateMailer).to receive(:referees_did_not_respond_before_end_of_cycle).and_call_original
      allow(CandidateInterface::RejectAwaitingReferencesApplication).to receive(:call).and_call_original
      RejectAwaitingReferencesCourseChoicesWorker.new.perform

      expect(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to have_received(:call)
      expect(CandidateMailer).to have_received(:referees_did_not_respond_before_end_of_cycle).with(application_choice.application_form)
      expect(CandidateInterface::RejectAwaitingReferencesApplication).to have_received(:call).with(application_choice)
      expect(CandidateInterface::RejectAwaitingReferencesApplication).not_to have_received(:call).with(application_choice_withdrawn)
    end
  end
end
