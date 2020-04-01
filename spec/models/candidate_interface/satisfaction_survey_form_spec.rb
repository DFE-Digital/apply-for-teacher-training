require 'rails_helper'

RSpec.describe CandidateInterface::SatisfactionSurveyForm, type: :model do
  describe '#save' do
    context 'when the user respodns with strongly agree or strongly disagree' do
      it 'only saves the number in the string and updates the satisfaction_survey on the application_form' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', response: '1 - strongly agree').save(application_form)

        expect(application_form.satisfaction_survey).to eq({ 'How was your experience' => '1' })
      end
    end

    context 'when the user responds with any other response' do
      it 'updates the satisfaction_survey on the application_form with their response' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', response: '2').save(application_form)

        expect(application_form.satisfaction_survey).to eq({ 'How was your experience' => '2' })
      end
    end
  end
end
