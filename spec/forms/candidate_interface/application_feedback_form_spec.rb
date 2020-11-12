require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackForm, type: :model do
  let(:form) do
    described_class.new(
      path: 'candidate/application/references/type/edit/1',
      page_title: t('page_titles.references_type'),
      need_more_information: 'true',
      answer_does_not_fit_format: 'true',
      other_feedback: 'This would be easier if i could read.',
      consent_to_be_contacted: 'false',
    )
  end

  let(:application_form) { create(:application_form) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:page_title) }
    it { is_expected.to validate_presence_of(:consent_to_be_contacted) }

    describe '#path_is_valid' do
      it 'returns false if the path is not one of our endpoints' do
        invalid_form = described_class.new(
          path: 'invalid_path',
          page_title: t('page_titles.references_type'),
        )

        invalid_form.save(application_form)

        expect(invalid_form.errors.full_messages_for(:path)).not_to be_empty
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      application_form = double
      expect(described_class.new.save(application_form)).to eq(false)
    end

    it 'adds a new ApplicationFeedback object to the ApplicationForm if valid' do
      form.save(application_form)
      feedback = application_form.application_feedback.last

      expect(application_form.application_feedback.count).to eq 1
      expect(feedback.path).to eq form.path
      expect(feedback.page_title).to eq form.page_title
      expect(feedback.does_not_understand_section).to eq false
      expect(feedback.need_more_information).to eq true
      expect(feedback.answer_does_not_fit_format).to eq true
      expect(feedback.other_feedback).to eq 'This would be easier if i could read.'
      expect(feedback.consent_to_be_contacted).to eq false
    end
  end
end

ed
