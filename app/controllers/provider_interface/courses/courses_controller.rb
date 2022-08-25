module ProviderInterface
  module Courses
    class CoursesController < ProviderInterface::CoursesController
      def edit
        @wizard = CourseWizard.new(change_course_store, { current_step: 'courses', action: })
        @wizard.save_state!

        @courses = available_courses(@wizard.provider_id)
      end

      def update
        @wizard = CourseWizard.new(change_course_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :course, @wizard.next_step]
        else
          @courses = available_courses(@wizard.provider_id)
          track_validation_error(@wizard)

          render :edit
        end
      end

    private

      def course_params
        params.require(:provider_interface_course_wizard).permit(:course_id)
      end

      def attributes_for_wizard
        course_params.to_h.merge!(current_step: 'courses')
      end
    end
  end
end
