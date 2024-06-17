module CandidateInterface
  module References
    class BaseController < SectionController
      before_action :set_reference_process
      before_action :render_application_feedback_component, :set_reference, :set_edit_backlink
      before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

    private

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def next_step
        redirect_to return_to_path
      end

      def redirect_to_review_page_unless_reference_is_editable
        policy = ReferenceActionsPolicy.new(@reference)

        redirect_to candidate_interface_references_review_path if @reference.blank? || !policy.editable?
      end

      def set_edit_backlink
        @edit_backlink = params[:return_to_path] || candidate_interface_references_review_path(params[:reference_process]) ### Do we get into this or? Can we remove it?
      end

      def set_reference_process
        @reference_process = params[:reference_process]
      end
    end
  end
end
