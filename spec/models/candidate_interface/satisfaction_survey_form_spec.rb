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

<<<<<<< HEAD
    context 'when valid' do
      it 'updates the satisfaction_survey on the application_form with their answer' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', answer: '2').save(application_form)
=======
    context 'when the satisfcation_survey is nil and the user responds with strongly agree or strongly disagree' do
      it 'only saves the number in the string and updates the satisfaction_survey on the application_form' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', response: '1 - strongly agree').save(application_form)

        expect(application_form.satisfaction_survey).to eq({ 'How was your experience' => '1' })
      end
    end

    context 'when the the satisfcation_survey is nil and user responds with any other response' do
      it 'updates the satisfaction_survey on the application_form with their response' do
        application_form = create(:application_form)
        described_class.new(question: 'How was your experience', response: '2').save(application_form)
>>>>>>> Adds logic for adding new values to the survey and editing previous responses

        expect(application_form.satisfaction_survey).to eq({ 'How was your experience' => '2' })
      end
    end

    context 'when the the satisfcation_survey is present and the question exists as a key' do
      it 'updates their response' do
        application_form = create(:application_form, satisfaction_survey: {
          'How was your experience' => '2',
          'I found this service unnecessarily complex' => '4',
          })
        described_class.new(question: 'How was your experience', response: '3').save(application_form)

        expect(application_form.satisfaction_survey).to eq(
          {
            'How was your experience' => '3',
            'I found this service unnecessarily complex' => '4',
          },
        )
      end
    end

    context 'when the the satisfcation_survey is present and the question does not exist as a key' do
      it 'adds their response to the satisfaction survey' do
        application_form = create(:application_form, satisfaction_survey: { 'How was your experience' => '2' })
        described_class.new(question: 'I found this service unnecessarily complex', response: '3').save(application_form)

        expect(application_form.satisfaction_survey).to eq(
          {
            'How was your experience' => '2',
            'I found this service unnecessarily complex' => '3',
          },
        )
      end
    end
  end
end
