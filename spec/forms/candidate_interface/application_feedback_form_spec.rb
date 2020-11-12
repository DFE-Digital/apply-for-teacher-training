require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackForm, type: :model do
  let(:form) do
    described_class.new(
      issues: 'true',
      section: 'application_references',
      path: 'candidate_interface_references_edit_type_path',
      page_title: t('page_titles.references_type'),
      id_in_path: '1',
    )
  end

  let(:application_form) { create(:application_form) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:issues).on(:save) }
    it { is_expected.to validate_presence_of(:section).on(:save) }
    it { is_expected.to validate_presence_of(:path).on(:save) }
    it { is_expected.to validate_presence_of(:page_title).on(:save) }
    it { is_expected.to validate_presence_of(:consent_to_be_contacted).on(:update) }

    describe '#path_is_valid' do
      it 'returns false if the path is not one of our endpoints' do
        invalid_form = described_class.new(
          issues: 'true',
          section: 'application_references',
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
      expect(feedback.issues).to eq true
      expect(feedback.section).to eq form.section
      expect(feedback.path).to eq form.path
      expect(feedback.page_title).to eq form.page_title
      expect(feedback.id_in_path).to eq 1
    end
  end

  describe '#update' do
    let(:form) do
      described_class.new(
        need_more_information: 'true',
        answer_does_not_fit_format: 'true',
        other_feedback: 'This would be easier if i could read.',
        consent_to_be_contacted: 'false',
      )
    end

    it 'returns false if not valid' do
      application_feedback = double
      expect(described_class.new.save(application_feedback)).to eq(false)
    end

    it 'updates the ApplicationFeedback object and ensures booleans with missing values are set to false' do
      feedback = create(:application_feedback, other_feedback: nil)

      form.update(feedback)

      expect(feedback.does_not_understand_section).to eq false
      expect(feedback.need_more_information).to eq true
      expect(feedback.answer_does_not_fit_format).to eq true
      expect(feedback.other_feedback).to eq 'This would be easier if i could read.'
      expect(feedback.consent_to_be_contacted).to eq false
    end
  end

  describe '#has_issues?' do
    it 'returns true when issues is "true"' do
      expect(form.has_issues?).to eq true
    end

    it 'returns false when issues is not "true"' do
      form = described_class.new(issues: 'false')
      expect(form.has_issues?).to eq false
    end
  end
end
