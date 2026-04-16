module CandidateInterface
  module CourseChoices
    class VisaExpiryInterruptionController < BaseController
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached

      def new
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
          application_choice:,
        )
        @application_choice = application_choice
        @find_provider_url = application_choice.find_provider_url
        @find_url_with_visa_filter = "#{find_url}/results?can_sponsor_visa=true"
        @back_link = if params[:return_to] == 'review'
                       candidate_interface_course_choices_course_review_path
                     else
                       @wizard.previous_step_path
                     end
      end

    private

      def current_step
        :visa_expiry_interruption
      end
    end
  end
end
