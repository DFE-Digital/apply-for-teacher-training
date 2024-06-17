module CandidateInterface
  module References
    class EmailAddressController < BaseController
      include RequestReferenceOfferDashboard

      before_action :redirect_to_review_page_unless_reference_is_editable, :verify_email_is_editable
      before_action :set_edit_backlink, only: %i[edit update]
      before_action :application_choice ##### BASE CONTROLLER?
      before_action :set_wizard, only: %i[create update]

      def new
        @wizard = ReferenceWizard.new(
          current_step: :reference_email_address,
          step_params: ActionController::Parameters.new(
            {
              reference_email_address: {
                email_address: @reference.blank? ? nil : @reference.email_address
              }
            }
          )
        )
      end

      def edit
        @wizard = ReferenceWizard.new(
          current_step: :reference_email_address,
          step_params: ActionController::Parameters.new(
            {
              reference_email_address: {
                email_address: @reference.email_address
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
          current_step: :reference_email_address,
          reference_process: @reference_process,
          application_choice: @application_choice,
          current_application: current_candidate.current_application,
          reference: @reference,
          return_to_path: params[:return_to_path],
          step_params: ActionController::Parameters.new(
            {
              reference_email_address: {
                email_address: params.dig(:email_address, :email_address)
              }
            }
          )
        )
      end

      def next_path
        candidate_interface_references_relationship_path(@reference.id)
      end

      def referee_email_address_param
        strip_whitespace(params)
          .require(:candidate_interface_reference_referee_email_address_form).permit(:email_address)
          .merge!(reference_id: @reference.id)
      end

      def verify_email_is_editable
        policy = ReferenceActionsPolicy.new(@reference)
        return if policy.editable? || @reference.email_bounced?

        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
