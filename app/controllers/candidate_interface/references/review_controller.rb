module CandidateInterface
  module References
    class ReviewController < BaseController
      include ReferenceBeforeActions

      before_action :set_references, only: %i[show complete]
      before_action :set_destroy_backlink, only: %i[confirm_destroy_reference]
      before_action :redirect_to_review_page, unless: -> { @reference }, only: %i[confirm_destroy_reference destroy]
      skip_before_action ::UnsuccessfulCarryOverFilter, only: %i[confirm_destroy_reference destroy]
      skip_before_action ::CarryOverFilter, only: %i[confirm_destroy_reference destroy]
      before_action :set_policy, only: %i[new review request_feedback]
      before_action :verify_reference_can_be_requested, only: %i[request_feedback]

      def show
        @section_complete_form = ReferenceSectionCompleteForm.new(
          completed: current_application.references_completed,
        )
      end

      def new
        @request_reference = ::RequestReference.new
      end

      def review
        render_404 if @reference.nil? && @reference_process == 'request-reference'
        @request_reference = ::RequestReference.new
      end

      def complete
        @application_form = current_application
        @section_complete_form = ReferenceSectionCompleteForm.new(
          application_form_params.merge(application_form: @application_form),
        )

        if @application_form.complete_references_information? && @section_complete_form.save(current_application, :references_completed)
          redirect_to_new_continuous_applications_if_eligible
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def request_feedback
        @request_reference = ::RequestReference.new(reference: @reference)

        if @request_reference.send_request
          flash[:success] = "Reference request sent to #{@reference.name}"

          redirect_to candidate_interface_application_offer_dashboard_path
        else
          track_validation_error(@request_reference)
          render :new
        end
      end

      def confirm_destroy_reference; end

      def destroy
        if @reference_process == 'accept-offer'
          ApplicationForm.with_unsafe_application_choice_touches do
            @reference.destroy
          end

          redirect_to candidate_interface_accept_offer_path(@application_choice)
        else
          DeleteReference.new.call(reference: @reference)

          VerifyAndMarkReferencesIncomplete.new(current_application).call

          redirect_to_review_page # what is dis?
        end
      end

      def destroy_reference_path
        candidate_interface_destroy_new_reference_path(
          @reference_process,
          @reference,
          application_id: @application_choice&.id,
        )
      end
      helper_method :destroy_reference_path

    private

      def redirect_to_review_page
        redirect_to candidate_interface_references_review_path
      end

      def set_references
        @references = current_application.application_references.includes(:application_form)
      end

      def set_destroy_backlink
        @destroy_backlink =
          if @reference_process == 'accept-offer'
            candidate_interface_accept_offer_path(@application_choice)
          else
            candidate_interface_references_review_path
          end
      end

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_reference_section_complete_form, {}).permit(:completed)
      end

      def set_policy
        @policy = ReferenceActionsPolicy.new(@reference)
      end

      def verify_reference_can_be_requested
        render_404 and return unless @policy.can_request?
      end
    end
  end
end
