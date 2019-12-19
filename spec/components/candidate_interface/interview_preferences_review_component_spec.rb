require 'rails_helper'

RSpec.describe CandidateInterface::InterviewPreferencesReviewComponent do
  let(:application_form) { build_stubbed(:application_form, interview_preferences: Faker::Lorem.paragraph_by_chars(number: 100)) }

  context 'when interview preferences is editable' do
    it 'renders SummaryCardComponent with interview preferences' do
      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include(application_form.interview_preferences)
      expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.personal_statement.interview_preferences.change_action')}")
    end

    it 'renders with "None" if value of interview preferences is an empty string' do
      application_form.interview_preferences = ''

      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include('None')
    end
  end

  context 'when interview preferences is not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class, application_form: application_form, editable: false)

      expect(result.css('.govuk-summary-list__actions').text).not_to include("Change #{t('application_form.personal_statement.interview_preferences.change_action')}")
    end
  end
end
