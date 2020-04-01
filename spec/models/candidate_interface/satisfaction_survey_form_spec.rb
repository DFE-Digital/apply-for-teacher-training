require 'rails_helper'

RSpec.describe CandidateInterface::SatisfactionSurveyForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:question) }

    context 'when question is not in the QUESTIONS_ASKED constant' do
      it 'is not valid' do
        application_form = create(:application_form)
        expect(described_class.new(question: 'This is an invalid question', answer: '2').save(application_form)).to be_falsey
      end
    end
  end

  describe '#save' do
    context 'when not valid' do
      it 'return false' do
        application_form = double

        form = described_class.new({})
        expect(form.save(application_form)).to eq(false)
      end
    end

    context 'when the the satisfcation_survey is nil' do
      it 'updates the satisfaction_survey on the application_form with their answer' do
        application_form = create(:application_form)
        described_class.new(question: 'I would recommend this service to a friend or colleague', answer: '2').save(application_form)

        expect(application_form.satisfaction_survey).to eq({ 'I would recommend this service to a friend or colleague' => '2' })
      end
    end

    context 'when the the satisfcation_survey is present and the question exists as a key' do
      it 'updates their answer' do
        application_form = create(:application_form, satisfaction_survey: {
          'I would recommend this service to a friend or colleague' => '2',
          'I found this service unnecessarily complex' => '4',
          })
        described_class.new(question: 'I would recommend this service to a friend or colleague', answer: '3').save(application_form)

        expect(application_form.satisfaction_survey).to eq(
          {
            'I would recommend this service to a friend or colleague' => '3',
            'I found this service unnecessarily complex' => '4',
          },
        )
      end
    end

    context 'when the the satisfcation_survey is present and the question does not exist as a key' do
      it 'adds their answer to the satisfaction survey' do
        application_form = create(:application_form, satisfaction_survey: { 'I would recommend this service to a friend or colleague' => '2' })
        described_class.new(question: 'I found this service unnecessarily complex', answer: '3').save(application_form)

        expect(application_form.satisfaction_survey).to eq(
          {
            'I would recommend this service to a friend or colleague' => '2',
            'I found this service unnecessarily complex' => '3',
          },
        )
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
