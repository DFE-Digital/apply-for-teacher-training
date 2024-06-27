module CandidateInterface
  module References
    class RelationshipController < BaseController
      include ReferenceBeforeActions

      before_action :redirect_to_review_page_unless_reference_is_editable
      before_action :set_wizard, only: %i[new edit create update]

      def new; end

      def edit; end

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
                relationship: params.dig(:relationship, :relationship) || @reference&.relationship,

              },
            },
          ),
        )
      end
    end
  end
end
