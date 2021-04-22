require 'rails_helper'

RSpec.describe CandidateInterface::SubjectKnowledgeReviewComponent do
  let(:application_form) { build_stubbed(:completed_application_form) }

  context 'when subject knowledge is editable' do
    it 'renders SummaryCardComponent with valid becoming a teacher' do
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(application_form.subject_knowledge)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.personal_statement.subject_knowledge.change_action')}")
    end
  end

  context 'when subject knowledge is not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.govuk-summary-list__actions').text).not_to include("Change #{t('application_form.personal_statement.subject_knowledge.change_action')}")
    end
  end

  describe 'submitting app' do
    let(:result) { render_inline(described_class.new(application_form: application_form, submitting_application: true)) }

    context 'section not complete' do
      before { application_form.subject_knowledge_completed = false }

      context 'when review is pending' do
        before { allow(application_form).to receive(:review_pending?).with(:subject_knowledge).and_return(true) }

        it 'shows review-related messaging' do
          expect(result.text).to include(t('review_application.subject_knowledge.not_reviewed'))
        end
      end

      context 'when review is not pending' do
        before { allow(application_form).to receive(:review_pending?).with(:subject_knowledge).and_return(false) }

        it 'shows section missing messaging' do
          expect(result.text).to include(t('review_application.subject_knowledge.incomplete'))
        end
      end
    end
  end
end
