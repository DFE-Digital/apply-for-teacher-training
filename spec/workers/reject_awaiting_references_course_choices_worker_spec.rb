require 'rails_helper'

RSpec.describe RejectAwaitingReferencesCourseChoicesWorker do
  describe '#perform' do
    it 'calls the `GetAwaitingReferencesCourseChoicesForPreviousCycle` service' do
      allow(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to receive(:call).and_return([])
      RejectAwaitingReferencesCourseChoicesWorker.new.perform

      expect(CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications).to have_received(:call)
    end
  end
end
