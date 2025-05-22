require 'rails_helper'

RSpec.describe Candidate::PoolEligibleApplicationFormWorker do
  describe '#perform' do
    let(:worker) { described_class.new.perform }

    it 'creates PoolEligibleApplicationForm records' do
      rejected_candidate = create(:candidate)
      rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
      create(:pool_eligible_application_form, application_form: rejected_candidate_form)
      create(:candidate_preference, candidate: rejected_candidate)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)

      expect { worker }.to change(PoolEligibleApplicationForm, :count).by(1)
      expect(PoolEligibleApplicationForm.last.application_form_id).to eq(
        rejected_candidate_form.id,
      )
    end

    context 'when there are no application_forms' do
      it 'creates PoolEligibleApplicationForm records' do
        expect { worker }.not_to change(PoolEligibleApplicationForm, :count)
      end
    end
  end
end
