require 'rails_helper'

RSpec.describe UnsubmittedApplicationChoicesForCourse do
  describe '#call' do
    it 'returns the unsubmitted choices for this course' do
      provider = create(:provider)
      course = create(:course, provider: provider)
      course_option = create(:course_option, course:)
      application_form = create(:application_form, :minimum_info)
      application_choice = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
        current_course_option: course_option,
      )

      different_course = create(:course, provider: provider)
      different_course_option = create(:course_option, course: different_course)
      _different_application_choice = create(
        :application_choice,
        application_form:,
        status: 'unsubmitted',
        current_course_option: different_course_option,
      )

      _submitted_application_choice = create(
        :application_choice,
        application_form:,
        status: 'awaiting_provider_decision',
        current_course_option: course_option,
      )

      expect(described_class.call(course.id)).to eq([application_choice])
    end
  end
end
