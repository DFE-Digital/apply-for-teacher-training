module CandidateInterface
  module References
    class RelationshipController < BaseController
      include RequestReferenceOfferDashboard

      before_action :redirect_to_review_page_unless_reference_is_editable
      before_action :set_edit_backlink, only: %i[edit update]
      before_action :application_choice
      before_action :set_wizard, only: %i[create update]

      # Dynamically do this?
      #skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited, if: -> { params[:reference_process] == 'request-reference'}

      def new
        @wizard = ReferenceWizard.new(
          current_step: :reference_relationship,
          reference: @reference,
          step_params: ActionController::Parameters.new(
            {
              reference_relationship: {
                relationship: @reference.relationship.blank? ? nil :@reference.relationship
              }
            }
          )
        )
      end

      def edit
        @wizard = ReferenceWizard.new(
          current_step: :reference_relationship,
          reference: @reference,
          step_params: ActionController::Parameters.new(
            {
              reference_relationship: {
                relationship: @reference.relationship
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
          current_step: :reference_relationship,
          reference_process: @reference_process,
          application_choice: @application_choice,
          return_to_path: params[:return_to_path],
          reference: @reference,
          step_params: ActionController::Parameters.new(
            {
              reference_relationship: {
                relationship: params.dig(:relationship, :relationship)
              }
            }
          )
        )
      end

      def references_relationship_params
        strip_whitespace params.require(:candidate_interface_reference_referee_relationship_form).permit(:relationship)
      end
    end
  end
end
