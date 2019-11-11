require 'rails_helper'

RSpec.describe BecomingATeacherReviewComponent do
  it 'renders SummaryCardComponent with valid becoming a teacher' do
    application_form = create(:application_form, :completed_application_form)
    result = render_inline(BecomingATeacherReviewComponent, application_form: application_form)

    expect(result.text).to include(application_form.becoming_a_teacher)
  end
end
