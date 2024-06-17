module CandidateInterface
  module References
    class TypeController < BaseController
      include RequestReferenceOfferDashboard

      before_action :verify_type_is_editable, only: %i[new create]
      before_action :redirect_to_review_page_unless_reference_is_editable, :set_edit_backlink, only: %i[edit update]
      before_action :set_application_choice ### base controller?
      before_action :set_wizard, only: %i[create update]

      def new
        @wizard = ReferenceWizard.new(
          current_step: :reference_type,
          step_params: ActionController::Parameters.new(
            {
              reference_type: {
                referee_type: params[:referee_type] # should we make a params method that works for all controller methods?
              }
            }
          )
        )
      end

      def edit
        @wizard = ReferenceWizard.new(
          current_step: :reference_type,
          step_params: ActionController::Parameters.new(
            {
              reference_type: {
                referee_type: @reference.referee_type # should we make a params method that works for all controller methods?
              }
            }
          )
        )
      end

      def create
        if @wizard.valid_step?
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

      def set_application_choice
        @application_choice ||= @current_application.application_choices.find_by_id(params[:application_id])
      end

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_type,
          reference_process: @reference_process,
          reference: @reference,
          application_choice: @application_choice,
          return_to_path: params[:return_to_path],
          step_params: ActionController::Parameters.new(
            {
              reference_type: {
                referee_type: params.dig(:type, :referee_type)
              }
            }
          )
        )
      end

      def referee_type_param
        #params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
        #params.permit!
        params.dig(:type, :referee_type)
      end

      def verify_type_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        return if @reference.blank? || (@reference.present? && policy.editable?)

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
