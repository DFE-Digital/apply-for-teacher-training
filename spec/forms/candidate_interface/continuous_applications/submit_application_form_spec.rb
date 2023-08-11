require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::SubmitApplicationForm, continuous_applications: true do
  subject(:submit_application_form) { described_class.new(attributes) }

  let(:attributes) { { application_choice: } }
  let(:application_form) { create(:application_form) }
  let(:application_choice) { create(:application_choice, application_form:) }

  context 'validations' do
    context 'when no answer is provider' do
      it 'adds error to submit answer' do
        expect(submit_application_form.valid?).to be_falsey
        expect(submit_application_form.errors[:submit_answer]).to be_present
      end
    end
  end

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
