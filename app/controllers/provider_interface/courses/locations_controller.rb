module ProviderInterface
  module Courses
    class LocationsController < CoursesController
      def edit
        @wizard = CourseWizard.new(change_course_store, { current_step: 'locations', action: })
        @wizard.save_state!

        @course_options = available_course_options(@wizard.course_id, @wizard.study_mode).includes([:site])
      end

      def update
        @wizard = CourseWizard.new(change_course_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :course, @wizard.next_step]
        else
          @course_options = available_course_options(@wizard.course_id, @wizard.study_mode)
          track_validation_error(@wizard)

          render :edit
        end
      end

    private

      def course_option_params
        params.expect(provider_interface_course_wizard: [:course_option_id])
      end

      def attributes_for_wizard
        course_option_params.to_h.merge!(current_step: 'locations')
      end
    end
  end
end
