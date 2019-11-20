require 'rails_helper'

RSpec.describe SubjectKnowledgeReviewComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when subject knowledge is editable' do
    it 'renders SummaryCardComponent with valid becoming a teacher' do
      result = render_inline(SubjectKnowledgeReviewComponent, application_form: application_form)

      expect(result.text).to include(application_form.subject_knowledge)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.personal_statement.subject_knowledge.change_action')}")
    end
  end

  context 'when subject knowledge is not editable' do
    it 'renders component without an edit link' do
      result = render_inline(SubjectKnowledgeReviewComponent, application_form: application_form, editable: false)

      expect(result.css('.govuk-summary-list__actions').text).not_to include("Change #{t('application_form.personal_statement.subject_knowledge.change_action')}")
    end
  end
end
