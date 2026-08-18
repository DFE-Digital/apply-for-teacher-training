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

      def step_params
        ActionController::Parameters.new(
          {
            current_step => {
              application_choice_id: application_choice.id,
              visa_explanation: params.dig(current_step, :visa_explanation) || application_choice.visa_explanation,
              visa_explanation_details: params.dig(current_step, :visa_explanation_details) || application_choice.visa_explanation_details,
            },
          },
        )
      end

      def update_params
        step_params
      end
    end
  end
end
