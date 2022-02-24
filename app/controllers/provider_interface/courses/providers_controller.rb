module ProviderInterface
  module Courses
    class ProvidersController < CoursesController
      def edit
        @wizard = CourseWizard.new(change_course_store, { current_step: 'providers', action: action })
        @wizard.save_state!

        @providers = available_providers
      end

      def update
        @wizard = CourseWizard.new(change_course_store, attributes_for_wizard)

        if @wizard.valid_for_current_step?
          @wizard.save_state!

          redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
        else
          track_validation_error(@wizard)
          @providers = available_providers

          render :edit
        end
      end

    private

      def provider_params
        params.require(:provider_interface_course_wizard).permit(:provider_id)
      end

      def attributes_for_wizard
        provider_params.to_h.merge!(current_step: 'providers')
      end
    end
  end
end
