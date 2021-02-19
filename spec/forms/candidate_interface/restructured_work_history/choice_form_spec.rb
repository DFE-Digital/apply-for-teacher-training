require 'rails_helper'

RSpec.describe CandidateInterface::RestructuredWorkHistory::ChoiceForm, type: :model do
  describe 'validations' do
    let(:form) { subject }

    before do
      allow(form).to receive(:can_not_complete_work_history?).and_return(true)
    end

    it { is_expected.to validate_presence_of(:choice) }
    it { is_expected.to validate_presence_of(:explanation) }

    valid_text = Faker::Lorem.sentence(word_count: 400)
    invalid_text = Faker::Lorem.sentence(word_count: 401)

    it { is_expected.to allow_value(valid_text).for(:explanation) }
    it { is_expected.not_to allow_value(invalid_text).for(:explanation) }
  end

  describe '.build_from_application' do
    it 'sets the choice and explanation values' do
      application_form = create(
        :application_form,
        work_history_status: :can_not_complete,
        work_history_explanation: 'I have been a full time parent',
      )
      choice_form = described_class.build_from_application(application_form)

      expect(choice_form.choice).to eq 'can_not_complete'
      expect(choice_form.explanation).to eq 'I have been a full time parent'
    end
  end

  describe '.save' do
    it 'returns false if not valid' do
      choice_form = described_class.new

      expect(choice_form.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the work_history_status and work_history_explanation values' do
      application_form = create(:application_form)
      choice_form = described_class.new(
        choice: 'can_not_complete',
        explanation: 'I have been a full time parent',
      )

      expect(choice_form.save(application_form)).to eq(true)
      expect(application_form.work_history_status).to eq 'can_not_complete'
      expect(application_form.work_history_explanation).to eq 'I have been a full time parent'
    end
  end
end
