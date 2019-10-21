require 'rails_helper'

RSpec.describe PersonalDetailsReviewComponent do
  it 'renders SummaryCardComponent with valid personal details' do
    application_form = create(:application_form, :completed_application_form)
    result = render_inline(PersonalDetailsReviewComponent, application_form: application_form)

    expect(result.text).to include(application_form.first_name)
  end

  it 'renders fallback text with invalid personal details' do
    application_form = create(:application_form)
    result = render_inline(PersonalDetailsReviewComponent, application_form: application_form)

    expect(result.text).to include('No personal details entered')
  end
end
