require 'rails_helper'

RSpec.describe CandidateInterface::SatisfactionSurveyForm, type: :model do
  it { is_expected.to validate_presence_of(:question) }


  describe '#save' do
    context 'when not valid' do
      it 'return false' do
        application_form = double

        form = described_class.new({})
        expect(form.save(application_form)).to eq(false)
      end
    end

    context 'when valid' do
      it 'updates the satisfaction_survey on the application_form with their answer' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', answer: '2').save(application_form)

        expect(application_form.satisfaction_survey).to eq({ 'How was your experience' => '2' })
      end
    end
  end
end
