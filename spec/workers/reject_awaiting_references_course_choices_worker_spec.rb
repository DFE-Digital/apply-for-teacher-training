require 'rails_helper'

RSpec.describe RejectAwaitingReferencesCourseChoicesWorker do
  describe '#perform' do
    it 'calls the appropriate services' do
      application_choice = create(:application_choice, :awaiting_references)
      reference1 = create(:reference, :feedback_requested, application_form: application_choice.application_form)
      reference2 = create(:reference, :feedback_requested, application_form: application_choice.application_form)

      application_form = application_choice.application_form
      application_choice_withdrawn = create(:application_choice, :withdrawn, application_form: application_form)

      allow(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to receive(:call).and_return([application_choice.application_form])
      allow(CandidateMailer).to receive(:referees_did_not_respond_before_end_of_cycle).and_call_original
      allow(CandidateInterface::RejectAwaitingReferencesApplication).to receive(:call).and_call_original
      allow(CandidateInterface::CancelReferenceAtEndOfCycle).to receive(:call).and_return(true)

      RejectAwaitingReferencesCourseChoicesWorker.new.perform

      expect(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to have_received(:call)
      expect(CandidateMailer).to have_received(:referees_did_not_respond_before_end_of_cycle).with(application_choice.application_form)
      expect(CandidateInterface::RejectAwaitingReferencesApplication).to have_received(:call).with(application_choice)
      expect(CandidateInterface::RejectAwaitingReferencesApplication).not_to have_received(:call).with(application_choice_withdrawn)

      expect(CandidateInterface::CancelReferenceAtEndOfCycle).to have_received(:call).with(reference1)
      expect(CandidateInterface::CancelReferenceAtEndOfCycle).to have_received(:call).with(reference2)
    end
  end
end
