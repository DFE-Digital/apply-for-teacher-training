require 'rails_helper'

RSpec.describe BecomingATeacherReviewComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when becoming a teacher is editable' do
    it 'renders SummaryCardComponent with valid becoming a teacher' do
      result = render_inline(BecomingATeacherReviewComponent, application_form: application_form)

      expect(result.text).to include(application_form.becoming_a_teacher)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.personal_statement.becoming_a_teacher.change_action')}")
    end
  end

  context 'when becoming a teacher is not editable' do
    it 'renders component without an edit link' do
      result = render_inline(BecomingATeacherReviewComponent, application_form: application_form, editable: false)

      expect(result.css('.govuk-summary-list__actions').text).not_to include("Change #{t('application_form.personal_statement.becoming_a_teacher.change_action')}")
    end
  end
end
