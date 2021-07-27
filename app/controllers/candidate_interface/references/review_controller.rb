module CandidateInterface
  module References
    class ReviewController < BaseController
      before_action :redirect_to_start_path_if_candidate_has_no_references

      def show
        set_references
        @too_many_references = current_application.too_many_complete_references?
      end

      def unsubmitted
        redirect_to_review_page_unless_reference_is_editable

        @submit_reference_form = Reference::SubmitRefereeForm.new
      end

      def submit
        @submit_reference_form = Reference::SubmitRefereeForm.new(submit: submit_param, reference_id: @reference.id)

        if @submit_reference_form.valid?
          @candidate_name_form = Reference::CandidateNameForm.build_from_reference(@reference)

          if @submit_reference_form.send_request? && !@candidate_name_form.valid?
            redirect_to candidate_interface_references_new_candidate_name_path(@reference.id)
          elsif @submit_reference_form.send_request?
            RequestReference.new.call(@reference)
            flash[:success] = "Reference request sent to #{@reference.name}"
            redirect_to_review_page
          else
            redirect_to_review_page
          end
        else
          track_validation_error(@submit_reference_form)
          render :unsubmitted
        end
      end

      def confirm_destroy_referee
        unless @reference.present? && @reference.not_requested_yet?
          redirect_to_review_page
        end
      end

      def confirm_destroy_reference
        unless @reference.present? && @reference.feedback_provided?
          redirect_to_review_page
        end
      end

      def confirm_destroy_reference_request
        policy = ReferenceActionsPolicy.new(@reference)

        unless @reference.present? && policy.request_can_be_deleted?
          redirect_to_review_page
        end
      end

      def destroy
        policy = ReferenceActionsPolicy.new(@reference)

        unless @reference.present? && (policy.can_be_destroyed? || policy.request_can_be_deleted?)
          redirect_to_review_page and return
        end

        DeleteReference.new.call(reference: @reference)
        redirect_to_review_page
      end

      def confirm_cancel
        if @reference&.feedback_requested?
          @application_form = current_application
        else
          redirect_to_review_page
        end
      end

      def cancel
        if @reference&.feedback_requested?
          CancelReferee.new.call(reference: @reference)

          redirect_to_review_page
          flash[:success] = "Reference request cancelled for #{@reference.name}"
        else
          redirect_to_review_page
        end
      end

    private

      def submit_param
        params.dig(:candidate_interface_reference_submit_referee_form, :submit)
      end

      def redirect_to_review_page
        redirect_to candidate_interface_references_review_path
      end

      def redirect_to_start_path_if_candidate_has_no_references
        redirect_to candidate_interface_references_start_path if current_application.application_references.blank?
      end

      def section_complete_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end

      def set_references
        @references_selected = current_application.application_references.includes(:application_form).selected
        @references_given = current_application.application_references.includes(:application_form).feedback_provided
        @references_waiting_to_be_sent = current_application.application_references.includes(:application_form).not_requested_yet
        @references_sent = current_application.application_references.includes(:application_form).pending_feedback_or_failed
      end
    end
  end
end
