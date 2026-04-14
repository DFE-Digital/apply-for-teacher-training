module CandidateInterface
  module CourseChoices
    class VisaExpiryInterruptionController < CandidateInterface::CourseChoices::BaseController
      def new
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
          application_choice:,
        )
        @application_choice = application_choice
        @find_provider_url = application_choice.find_provider_url
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
