require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::SubmitApplicationForm do
  subject(:submit_application_form) { described_class.new(attributes) }

  describe '#submit_now?' do
    context 'when the answer is yes' do
      let(:attributes) { { submit_answer: 'yes' } }

      it 'returns true' do
        expect(submit_application_form.submit_now?).to be_truthy
      end
    end

    context 'when the answer is no' do
      let(:attributes) { { submit_answer: 'no' } }

      it 'returns false' do
        expect(submit_application_form.submit_now?).to be_falsey
      end
    end
  end
end
