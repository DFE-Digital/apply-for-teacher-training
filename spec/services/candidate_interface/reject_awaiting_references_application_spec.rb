require 'rails_helper'

RSpec.describe CandidateInterface::RejectAwaitingReferencesApplication do
  describe '#call' do
    let(:application_choice) { create(:awaiting_references_application_choice) }

    it 'rejects an application at the end of the cycle' do
      Timecop.freeze do
        described_class.call(application_choice)

        expect(application_choice.status).to eq 'rejected_at_end_of_cycle'
        expect(application_choice.rejection_reason).to eq 'Awaiting references when the recruitment cycle closed.'
        expect(application_choice.rejected_at).to eq Time.zone.now
      end
    end
  end
end
