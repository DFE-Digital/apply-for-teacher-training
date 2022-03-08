module ProviderInterface
  module Courses
    class ChecksController < CoursesController
      def edit
        @wizard = CourseWizard.new(change_course_store, { current_step: 'check', action: action })
        @wizard.save_state!

        @providers = available_providers
        @courses = available_courses(@wizard.provider_id)
        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)
      end
    end
  end
end
