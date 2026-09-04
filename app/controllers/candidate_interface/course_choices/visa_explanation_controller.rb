module CandidateInterface
  module CourseChoices
    class VisaExplanationController < BaseController
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached
      before_action :assign_wizard_with_application_choice

    private

      def current_step
        :visa_explanation
      end

      def wizard_controller?
        true
      end
    end
  end
end
