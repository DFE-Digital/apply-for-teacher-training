require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackForm, type: :model do
  let(:form) do
    described_class.new(
      path: 'candidate/application/references/type/edit/1',
      page_title: t('page_titles.references_type'),
      feedback: 'This would be easier if i could read.',
      consent_to_be_contacted: 'false',
    )
  end

  describe 'validations' do
    let(:application_form) { build(:application_form) }

    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:page_title) }
    it { is_expected.to validate_presence_of(:consent_to_be_contacted) }
    it { is_expected.to validate_presence_of(:feedback) }

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
    let(:application_form) { create(:application_form) }

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
      expect(feedback.feedback).to eq 'This would be easier if i could read.'
      expect(feedback.consent_to_be_contacted).to eq false
    end
  end
end
