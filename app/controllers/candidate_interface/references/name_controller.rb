module CandidateInterface
  module References
    class NameController < BaseController
      include RequestReferenceOfferDashboard

      before_action :verify_name_is_editable, only: %i[new create]
      before_action :redirect_to_review_page_unless_reference_is_editable, :set_edit_backlink, only: %i[edit update]
      before_action :application_choice
      before_action :set_wizard, only: %i[create update]

      def new
        @wizard = ReferenceWizard.new(
          current_step: :reference_name,
          step_params: ActionController::Parameters.new(
            {
              reference_name: {
                name: @reference.blank? ? nil : @reference.name
              }
            }
          )
        )
      end

      def edit
        @wizard = ReferenceWizard.new(
          current_step: :reference_name,
          step_params: ActionController::Parameters.new(
            {
              reference_name: {
                name: @reference.name
              }
            }
          )
        )
      end

      def create
        if @wizard.save
          redirect_to @wizard.next_step
        else
          track_validation_error(@wizard.current_step)
          render :new
        end
      end

      def update
        if @wizard.save
          redirect_to @wizard.next_step
        else
          track_validation_error(@wizard.current_step)
          render :edit
        end
      end

    private

      def application_choice
        @application_choice ||= @current_application.application_choices.find_by_id(params[:application_id])
      end

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_name,
          reference_process: @reference_process,
          application_choice: @application_choice,
          current_application:,
          reference: @reference,
          return_to_path: params[:return_to_path],
          step_params: ActionController::Parameters.new(
            {
              reference_name: {
                name: params.dig(:name, :name),
                referee_type: params[:referee_type] || @reference&.referee_type,
              }
            }
          )
        )
      end

      def referee_name_param
        strip_whitespace params.require(:candidate_interface_reference_referee_name_form).permit(:name)
      end

      def verify_name_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        return if @reference.blank? || (@reference.present? && policy.editable?)

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
