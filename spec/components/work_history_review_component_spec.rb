require 'rails_helper'

RSpec.describe WorkHistoryReviewComponent do
  it 'renders component with correct structure' do
    application_form = build(:completed_application_form, work_experiences_count: 1)

    result = render_inline(WorkHistoryReviewComponent, application_form: application_form)

    application_form.application_work_experiences.each do |work|
      expect(result.text).to include(work.role)
      expect(result.text).to include(work.start_date.strftime('%B %Y'))
      if work.working_with_children
        expect(result.text).to include(t('application_form.work_history.working_with_children'))
      end
    end
  end
end
