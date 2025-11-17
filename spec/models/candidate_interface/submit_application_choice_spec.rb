require 'rails_helper'

RSpec.describe CandidateInterface::SubmitApplicationChoice do
  let(:application_choice) { create(:application_choice, :unsubmitted) }
  let(:application_form) { application_choice.application_form }

  describe '#call' do
    context 'when the application form has a candidate pool application' do
      before do
        create(
          :candidate_pool_application,
          application_form: application_form,
          candidate: application_form.candidate,
        )
      end

      it 'destroys the pool application' do
        expect {
          described_class.new(application_choice).call
        }.to change(CandidatePoolApplication, :count).by(-1)
        expect(application_form.reload.candidate_pool_application).to be_nil
      end
    end
  end
end
