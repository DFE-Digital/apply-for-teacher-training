module CandidateInterface
  module DecoupledReferences
    class ReviewController < BaseController
      before_action :set_reference

      def show
        @application_form = current_application
        @references_given = current_application.application_references.includes(:application_form).feedback_provided
        @references_waiting_to_be_sent = current_application.application_references.includes(:application_form).not_requested_yet
        @references_sent = current_application.application_references.includes(:application_form).pending_feedback_or_failed
      end

      def unsubmitted
        @submit_reference_form = Reference::SubmitRefereeForm.new
      end

      def submit
        @submit_reference_form = Reference::SubmitRefereeForm.new(submit: submit_param, reference_id: @reference.id)

        if @submit_reference_form.valid?
          @candidate_name_form = Reference::CandidateNameForm.build_from_reference(@reference)

          if @submit_reference_form.send_request? && !@candidate_name_form.valid?
            redirect_to candidate_interface_decoupled_references_new_candidate_name_path(@reference.id)
          elsif @submit_reference_form.send_request?
            CandidateInterface::DecoupledReferences::RequestReference.new.call(@reference, flash)
            redirect_to candidate_interface_decoupled_references_review_path
          else
            redirect_to candidate_interface_decoupled_references_review_path
          end
        else
          track_validation_error(@submit_reference_form)
          render :unsubmitted
        end
      end

      def confirm_destroy_referee
        redirect_to candidate_interface_decoupled_references_review_path and return if @reference.blank?
        redirect_to candidate_interface_decoupled_references_review_path and return unless @reference.not_requested_yet?
      end

      def confirm_destroy_reference
        redirect_to candidate_interface_decoupled_references_review_path and return if @reference.blank?
        redirect_to candidate_interface_decoupled_references_review_path and return unless @reference.feedback_provided?
      end

      def confirm_destroy_reference_request
        redirect_to candidate_interface_decoupled_references_review_path and return if @reference.blank?
        redirect_to candidate_interface_decoupled_references_review_path and return unless @reference.request_can_be_deleted?
      end

      def destroy
        redirect_to candidate_interface_decoupled_references_review_path and return if @reference.blank?
        redirect_to candidate_interface_decoupled_references_review_path and return unless @reference.can_be_destroyed? || @reference.request_can_be_deleted?

        @reference.destroy!
        redirect_to candidate_interface_decoupled_references_review_path
      end

      def confirm_cancel
        if @reference.feedback_requested?
          @application_form = current_application
        else
          redirect_to candidate_interface_decoupled_references_review_path
        end
      end

      def cancel
        if @reference.feedback_requested?
          CancelReference.call(@reference)

          redirect_to candidate_interface_decoupled_references_review_path
          flash[:success] = "Reference request cancelled for #{@reference.name}"
        else
          redirect_to candidate_interface_decoupled_references_review_path
        end
      end

    private

      def submit_param
        params.dig(:candidate_interface_reference_submit_referee_form, :submit)
      end
    end
  end
end
