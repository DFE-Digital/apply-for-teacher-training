module CandidateInterface
  module References
    class EmailAddressController < BaseController
      include ReferenceBeforeActions

      before_action :redirect_to_review_page_unless_reference_is_editable, :verify_email_is_editable
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
          current_step: :reference_email_address,
          reference_process: @reference_process,
          application_choice: @application_choice,
          current_application: current_candidate.current_application,
          reference: @reference,
          return_to_path: params[:return_to_path],
          step_params: ActionController::Parameters.new(
            {
              reference_email_address: {
                email_address: params.dig(:email_address, :email_address) || @reference&.email_address,
              },
            },
          ),
        )
      end

      def verify_email_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        return if policy.editable? || @reference.email_bounced?

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
