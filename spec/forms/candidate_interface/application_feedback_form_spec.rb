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
    it { is_expected.to validate_presence_of(:issues) }
    it { is_expected.to validate_presence_of(:section) }
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:page_title) }

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
