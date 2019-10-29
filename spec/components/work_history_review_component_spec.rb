require 'rails_helper'

RSpec.describe WorkHistoryReviewComponent do
  it 'renders component with correct structure' do
    application_form = build(:completed_application_form)

    result = render_inline(WorkHistoryReviewComponent, application_form: application_form)

    application_form.application_work_experiences.each do |work|
      expect(result.text).to include(work.role)
    end
  end
end
