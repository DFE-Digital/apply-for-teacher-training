require 'rails_helper'

RSpec.describe PersonalDetailsReviewComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when personal details are editable' do
    it 'renders SummaryCardComponent with valid personal details' do
      result = render_inline(PersonalDetailsReviewComponent, application_form: application_form)

      expect(result.text).to include(application_form.first_name)
      expect(result.text).to include('Change')
    end

    it 'renders fallback text with invalid personal details' do
      application_form = build_stubbed(:application_form)
      result = render_inline(PersonalDetailsReviewComponent, application_form: application_form)

      expect(result.text).to include('No personal details entered')
    end
  end

  context 'when personal details are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(PersonalDetailsReviewComponent, application_form: application_form, editable: false)

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
    end
  end
end
