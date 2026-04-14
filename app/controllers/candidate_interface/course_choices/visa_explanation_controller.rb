module CandidateInterface
  module CourseChoices
    class VisaExplanationController < BaseController
      def create
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
          application_choice:,
        )

        if @wizard.update_visa_explanation
          redirect_to @wizard.next_step_path
        else
          render :new
        end
      end

      def update
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
          application_choice:,
        )

        if @wizard.update_visa_explanation
          redirect_to @wizard.next_step_path
        else
          render :edit
        end
      end

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
